# ブックマークレット集: タブをmarkdownリンクで出力

実行したタブを `- [title](url)` 形式で出力する。ブックマークのURL欄に各節の1行を貼り付けて使用。Chrome・Firefoxの両方で動作し、環境に無いAPIは自動でフォールバックする。

目次

- [1. クリップボードにコピー](#1-クリップボードにコピー)
- [2. ファイルに保存(保存後にタブを閉じる)](#2-ファイルに保存保存後にタブを閉じる)
- [3. 自動追記(クリップボード連結)](#3-自動追記クリップボード連結)
- [4. Google翻訳(ページ内表示)](#4-google翻訳ページ内表示)
- [5. 決めたページをまとめて開く](#5-決めたページをまとめて開く)
- [6. ページ内リンクを一括収集](#6-ページ内リンクを一括収集)
- [7. ページをmarkdownでコピー](#7-ページをmarkdownでコピー)
- [8. ページ状態レポート(デバッグ用)](#8-ページ状態レポートデバッグ用)
- [9. 要素消去モード](#9-要素消去モード)

## 1. クリップボードにコピー

実行したタブの1行をクリップボードへ出力。プロンプトに前回の出力を貼ると追記モード(空=新規)。キャンセルで中止。タイトルの `\` `[` `]` とURLの `(` `)` は自動エスケープ(空白・改行は連続を1つに整理)。自動コピー失敗時(httpオリジン・権限切れなど)はテキストエリア経由で再試行し、それも失敗したら手動コピー用プロンプトを表示。

```javascript
javascript:(()=>{const p=prompt('前回のリストを貼って追記(空=新規):');if(p===null)return;const t=document.title.replace(/\\/g,'\\\\').replace(/[\[\]]/g,'\\$&').replace(/\s+/g,' ').trim(),u=location.href.replace(/\(/g,'%'+'28').replace(/\)/g,'%'+'29'),l=`- [${t}](${u})`,s=p?p+'\n'+l:l,fb=()=>{const ta=document.createElement('textarea');ta.value=s;ta.style.cssText='position:fixed;top:0;left:0;opacity:0';document.body.appendChild(ta);ta.select();document.execCommand('copy')||prompt('コピー失敗—手動でコピー:',s);ta.remove()};try{navigator.clipboard.writeText(s).catch(fb)}catch(e){fb()}})()
```

## 2. ファイルに保存(保存後にタブを閉じる)

各タブで[1]を実行して貯めたリストをプロンプトに貼り、`日付-ブラウザ名.md`(例: 2026-09-17-chrome.md)として保存。[File System Access API](https://developer.mozilla.org/docs/Web/API/File_System_API)対応環境では保存先を選び、書き込み完了後にタブを閉じる。キャンセル・空入力では中止し、保存先の選択や書き込みに失敗した場合はエラーを表示してタブを残す。API非対応環境(Firefoxなど)では従来のダウンロードを開始し、約0.4秒後にタブを閉じる。この経路では保存完了を確認できない。ブラウザの制限でタブが閉じない場合がある。保存先選択にはHTTPSなどの安全なコンテキストとユーザー操作が必要。

```javascript
javascript:(async()=>{const p=prompt('保存するリスト(- [title](url) 行):');if(p===null||!p.trim())return;const txt=p.trim()+'\n',d=new Date(),z=n=>String(n).padStart(2,'0'),dt=`${d.getFullYear()}-${z(d.getMonth()+1)}-${z(d.getDate())}`,ua=navigator.userAgent,b=/Edg\//.test(ua)?'edge':/OPR\//.test(ua)?'opera':/Firefox\//.test(ua)?'firefox':/Chrome\//.test(ua)?'chrome':/Safari\//.test(ua)?'safari':'browser',fn=`${dt}-${b}.md`,done=()=>{window.open('','_self');window.close()};if(typeof window.showSaveFilePicker==='function'){let h;try{h=await window.showSaveFilePicker({suggestedName:fn,types:[{description:'Markdown',accept:{'text/markdown':['.md']}}]})}catch(e){if(e.name!=='AbortError')alert('保存先を開けません: '+e.message);return}try{const w=await h.createWritable();await w.write(txt);await w.close()}catch(e){alert('保存失敗: '+e.message);return}done();return}const a=document.createElement('a');a.href=URL.createObjectURL(new Blob([txt],{type:'text/markdown'}));a.download=fn;document.body.appendChild(a);a.click();a.remove();setTimeout(()=>{URL.revokeObjectURL(a.href);done()},400)})()
```

## 3. 自動追記(クリップボード連結)

各タブで実行するだけで、現在のタブの1行を前回の出力に自動追記して書き戻す(前回のリストをプロンプトに貼る手間が不要)。初回は[クリップボード読み取り](https://developer.mozilla.org/docs/Web/API/Clipboard_API)の許可を求める。読み取りに失敗したオリジン(http・許可拒否など)では[1]と同じ貼り付けプロンプトに自動切替。同じ行が既にあれば二重追加せずそのままコピー。行の形式・エスケープは[1]と同じ。

```javascript
javascript:(()=>{const t=document.title.replace(/\\/g,'\\\\').replace(/[\[\]]/g,'\\$&').replace(/\s+/g,' ').trim(),u=location.href.replace(/\(/g,'%'+'28').replace(/\)/g,'%'+'29'),l=`- [${t}](${u})`,fb=s=>{const ta=document.createElement('textarea');ta.value=s;ta.style.cssText='position:fixed;top:0;left:0;opacity:0';document.body.appendChild(ta);ta.select();document.execCommand('copy')||prompt('コピー失敗—手動でコピー:',s);ta.remove()},done=s=>{try{navigator.clipboard.writeText(s).catch(()=>fb(s))}catch(e){fb(s)}},onRead=prev=>{const p=(prev||'').trim();if(p.split('\n').includes(l))return done(p);done(p?p+'\n'+l:l)},viaPrompt=()=>{const p=prompt('前回のリストを貼って追記(空=新規):');if(p!==null)onRead(p)};try{navigator.clipboard.readText().then(onRead,viaPrompt)}catch(e){viaPrompt()}})()
```

## 4. Google翻訳(ページ内表示)

現在のページをGoogle翻訳の日本語版(translate.googドメイン)で同じタブ内に開く。既に翻訳ページ上では何もしない。ホストの `-` は `--` にエンコード(例: my-site.example.com → my--site-example-com.translate.goog)。検索クエリ・パス・ハッシュは保持。

```javascript
javascript:(()=>{if(location.hostname.endsWith('.translate.goog'))return;const h=location.hostname.replace(/-/g,'--').replace(/\./g,'-'),u=new URL('https://'+h+'.translate.goog'+location.pathname);u.search=new URLSearchParams(location.search);u.searchParams.set('_x_tr_sl','auto');u.searchParams.set('_x_tr_tl','ja');u.searchParams.set('_x_tr_hl','ja');u.hash=location.hash;location.href=u})()
```

## 5. 決めたページをまとめて開く

実行のたびに決めたページセットをまとめて開く。スクリプト先頭の `d`(既定値)を普段使いのURL(空白/カンマ区切り)に書き換えて使う。プロンプトで都度編集も可。ポップアップブロックで開けなかった分はページ右上にパネル表示し、各URLのクリックで開ける(許可すれば次回から自動)。

```javascript
javascript:(()=>{const d='https://github.com https://youtube.com';const p=prompt('開くURL(空白/カンマ区切り):',d);if(p===null)return;const rest=[];for(const u of p.split(/[\s,]+/).filter(Boolean)){const w=window.open(u,'_blank');if(w)w.opener=null;else rest.push(u)}if(!rest.length)return;const box=document.createElement('div');box.style.cssText='position:fixed;top:12px;right:12px;z-index:2147483647;background:#fff;color:#000;border:2px solid #333;padding:12px;font:14px sans-serif';box.textContent='ポップアップブロック——各URLをクリック:';for(const u of rest){const a=document.createElement('a');a.href=u;a.target='_blank';a.rel='noopener';a.textContent=u;a.style.cssText='display:block;margin:6px 0';box.appendChild(a)}const b=document.createElement('button');b.textContent='閉じる';b.style.cssText='display:block;margin-top:8px';b.onclick=()=>box.remove();box.appendChild(b);document.body.appendChild(box)})()
```

## 6. ページ内リンクを一括収集

現在のページの全リンク(`a[href]`)を走査し、markdownリストとしてクリップボードへ一括コピー。同一URLの重複・ページ自身へのリンク・`href="#"`形式のページ内リンク・テキスト無し・`javascript:`/`mailto:`は除外。出現順。行の形式・エスケープは[1]と同じ。コピー不可環境では[1]と同じフォールバック。

```javascript
javascript:(()=>{const e=s=>s.replace(/\\/g,'\\\\').replace(/[\[\]]/g,'\\$&').replace(/\s+/g,' ').trim(),o=[],v=new Set(),pg=location.href.split('#')[0];for(const a of document.querySelectorAll('a[href]')){const u=a.href;if(!/^https?:/.test(u)||u===pg||v.has(u)||(a.getAttribute('href')||'').startsWith('#'))continue;const t=e(a.textContent);if(!t)continue;v.add(u);o.push(`- [${t}](${u.replace(/\(/g,'%'+'28').replace(/\)/g,'%'+'29')})`)}const s=o.join('\n');if(!s){alert('リンクが見つかりません');return}const fb=()=>{const ta=document.createElement('textarea');ta.value=s;ta.style.cssText='position:fixed;top:0;left:0;opacity:0';document.body.appendChild(ta);ta.select();document.execCommand('copy')||prompt('コピー失敗—手動でコピー:',s);ta.remove()};try{navigator.clipboard.writeText(s).catch(fb)}catch(x){fb()}})()
```

## 7. ページをmarkdownでコピー

現在のページ(選択範囲があればその部分のみ)を簡易markdown化してクリップボードへ。見出し・段落・リンク・画像・強調・コードブロック・リスト・引用・表を対象に、script/style/nav/footer/aside/form等のノイズを除去。冒頭にタイトルとURLを付記。行のエスケープは[1]と同じ。簡易変換のため入れ子リストは平滑化、複雑なレイアウトは崩れる場合あり。

```javascript
javascript:(()=>{const esc=s=>s.replace(/\\/g,'\\\\').replace(/[\[\]]/g,'\\$&').replace(/\s+/g,' ').trim(),pu=u=>u.replace(/\(/g,'%'+'28').replace(/\)/g,'%'+'29'),F='`'.repeat(3),root=document.createElement('div'),sel=getSelection();if(sel&&sel.rangeCount&&!sel.isCollapsed)root.appendChild(sel.getRangeAt(0).cloneContents());else root.appendChild((document.querySelector('main,article')||document.body).cloneNode(true));root.querySelectorAll('script,style,noscript,nav,footer,aside,form,svg,iframe,button').forEach(n=>n.remove());const conv=n=>{if(n.nodeType===3)return n.textContent;if(n.nodeType!==1)return '';const c=[...n.childNodes].map(conv).join(''),t=n.tagName;if(/^H[1-6]$/.test(t))return '\n\n'+'#'.repeat(+t[1])+' '+c.trim()+'\n\n';if(t==='P'||t==='DIV'||t==='SECTION'||t==='ARTICLE'||t==='MAIN'||t==='HEADER'||t==='FIGURE')return '\n\n'+c.trim()+'\n\n';if(t==='BR')return '\n';if(t==='HR')return '\n\n---\n\n';if(t==='A'){const h=n.href;return h&&/^https?:/.test(h)&&!(n.getAttribute('href')||'').startsWith('#')?`[${esc(c)||h}](${pu(h)})`:c}if(t==='IMG'){const s=n.src;return s&&/^https?:/.test(s)?`![${esc(n.getAttribute('alt')||'')}](${pu(s)})`:''}if(t==='STRONG'||t==='B')return c.trim()?'**'+c.trim()+'**':c;if(t==='EM'||t==='I')return c.trim()?'*'+c.trim()+'*':c;if(t==='CODE')return n.parentElement&&n.parentElement.tagName==='PRE'?c:c.trim()?'`'+c.trim()+'`':c;if(t==='PRE')return '\n\n'+F+'\n'+c.trim()+'\n'+F+'\n\n';if(t==='BLOCKQUOTE')return '\n\n'+c.trim().split('\n').map(l=>'> '+l).join('\n')+'\n\n';if(t==='UL'||t==='OL')return '\n\n'+[...n.children].map((li,i)=>(t==='OL'?(i+1)+'. ':'- ')+conv(li).trim().replace(/\n+/g,' ')).join('\n')+'\n\n';if(t==='TR')return '\n|'+[...n.children].map(td=>conv(td).trim().replace(/\n+/g,' ')).join(' | ')+' |';if(t==='TABLE')return '\n\n'+c.trim()+'\n\n';return c};const body=conv(root).replace(/\n{3,}/g,'\n\n').trim();if(!body){alert('コンテンツなし');return}const out='# '+document.title.replace(/\n/g,' ')+'\n\n'+location.href+'\n\n'+body+'\n';const fb=()=>{const ta=document.createElement('textarea');ta.value=out;ta.style.cssText='position:fixed;top:0;left:0;opacity:0';document.body.appendChild(ta);ta.select();document.execCommand('copy')||prompt('コピー失敗—手動でコピー:',out);ta.remove()};try{navigator.clipboard.writeText(out).catch(fb)}catch(x){fb()}})()
```

## 8. ページ状態レポート(デバッグ用)

ページの基本情報(タイトル・URL・UA・viewport・画面サイズ・devicePixelRatio・日時・選択範囲)とフォーム入力値をmarkdownレポート化してクリップボードへ。[Network Information API](https://developer.mozilla.org/docs/Web/API/Network_Information_API)対応環境(Chrome系のみ)では推定通信品質も記載する(`4g`などの値は実際の通信方式を示すものではない)。パスワード・ファイル・hidden入力の値は除外。エージェントへのバグ報告・状況共有用。実行前のコンソールエラーは取得できない(ブックマークレットからは過去のログへアクセス不可)。

```javascript
javascript:(()=>{const L=[],d=document,P=k=>L.push(k);P('# '+d.title.replace(/\n/g,' '));P('- URL: '+location.href);P('- viewport: '+window.innerWidth+'x'+window.innerHeight);P('- 画面: '+screen.width+'x'+screen.height+' @'+window.devicePixelRatio+'x');const cn=navigator.connection;if(cn&&cn.effectiveType)P('- 回線: '+cn.effectiveType);P('- UA: '+navigator.userAgent);P('- 日時: '+new Date().toLocaleString());const s=d.getSelection();if(s&&s.rangeCount&&!s.isCollapsed)P('- 選択: '+s.toString().replace(/\s+/g,' ').trim().slice(0,500));const fs=[...d.querySelectorAll('input,select,textarea')].filter(e=>e.type!=='hidden'&&e.type!=='password'&&e.type!=='file');if(fs.length){P('');P('## フォーム');for(const e of fs){const n=e.id||e.name||e.type;const v=(e.type==='checkbox'||e.type==='radio')?(e.checked?'on':'off'):String(e.value||'').slice(0,200);P(`- ${n}(${e.type}): ${v}`)}}const out=L.join('\n')+'\n';const fb=()=>{const ta=document.createElement('textarea');ta.value=out;ta.style.cssText='position:fixed;top:0;left:0;opacity:0';document.body.appendChild(ta);ta.select();document.execCommand('copy')||prompt('コピー失敗—手動でコピー:',out);ta.remove()};try{navigator.clipboard.writeText(out).catch(fb)}catch(x){fb()}})()
```

## 9. 要素消去モード

起動するとカーソルが十字になり、ホバー中の要素を赤枠表示。クリックでその要素を削除する(選択範囲のスクリーンショットやコピーの前掃除用)。再実行またはEscで終了。削除は再読み込みで元に戻る。ページのCSPによって赤枠などの表示が制限される場合がある。変更はそのページの表示のみに影響。

```javascript
javascript:(()=>{if(window.__erx){window.__erx();return}const st=document.createElement('style');st.textContent='html{cursor:crosshair!important}.__erx{outline:3px solid #e53935!important;outline-offset:-3px!important}';document.head.appendChild(st);const b=document.createElement('div');b.id='__erb';b.textContent='消去モード: クリックで要素削除 / Escで終了';b.style.cssText='position:fixed;left:8px;bottom:8px;z-index:2147483647;background:#111;color:#fff;padding:4px 10px;border-radius:4px;font:12px sans-serif';document.body.appendChild(b);let cur=null;const ov=e=>{if(cur)cur.classList.remove('__erx');cur=e.target;cur.classList.add('__erx')};const cl=e=>{const el=e.target;if(el.closest&&el.closest('#__erb'))return;if(el===document.documentElement||el===document.body)return;e.preventDefault();e.stopPropagation();el.remove();if(cur){cur.classList.remove('__erx');cur=null}};const key=e=>{if(e.key==='Escape')exit()};function exit(){document.removeEventListener('mouseover',ov,true);document.removeEventListener('click',cl,true);document.removeEventListener('keydown',key,true);if(cur)cur.classList.remove('__erx');st.remove();b.remove();delete window.__erx}document.addEventListener('mouseover',ov,true);document.addEventListener('click',cl,true);document.addEventListener('keydown',key,true);window.__erx=exit})();
```
