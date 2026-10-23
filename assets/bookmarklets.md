# Bookmarklets

`- [title](url)` 形式の出力は1〜3・6・10。ブックマークのURL欄に各節の1行を貼り付けて使用。Chrome・Firefoxの両方で動作し、環境に無いAPIは自動でフォールバックする。10は「全タブをブックマーク」で書き出したHTMLから一括でリスト化する。

目次

- [1. クリップボードにコピー](#1-クリップボードにコピー)
- [2. ファイルに保存](#2-ファイルに保存)
- [3. 自動追記(クリップボード連結)](#3-自動追記クリップボード連結)
- [4. Google翻訳(ページ内表示)](#4-google翻訳ページ内表示)
- [5. 決めたページをまとめて開く](#5-決めたページをまとめて開く)
- [6. ページ内リンクを一括収集](#6-ページ内リンクを一括収集)
- [7. ページをMarkdownでコピー](#7-ページをmarkdownでコピー)
- [8. ページ状態レポート(デバッグ用)](#8-ページ状態レポートデバッグ用)
- [9. 要素消去モード](#9-要素消去モード)
- [10. 全タブを一括でリスト化(書き出しHTMLから)](#10-全タブを一括でリスト化書き出しhtmlから)

## 1. クリップボードにコピー

実行したタブの1行をクリップボードへ出力。プロンプトに前回の出力を貼ると追記モード(空=新規)。キャンセルで中止。タイトルの `\` `[` `]` とURLの `(` `)` は自動エスケープ(空白・改行は連続を1つに整理)。自動コピー失敗時(httpオリジン・権限切れなど)はテキストエリア経由で再試行し、それも失敗したら手動コピー用プロンプトを表示。

```javascript
javascript:(()=>{const p=prompt('前回のリストを貼って追記(空=新規):');if(p===null)return;const t=document.title.replace(/\\/g,'\\\\').replace(/[\[\]]/g,'\\$&').replace(/\s+/g,' ').trim(),u=location.href.replace(/\(/g,'%'+'28').replace(/\)/g,'%'+'29'),l=`- [${t}](${u})`,s=p?p+'\n'+l:l,fb=()=>{const ta=document.createElement('textarea');ta.value=s;ta.style.cssText='position:fixed;top:0;left:0;opacity:0';document.body.appendChild(ta);ta.select();document.execCommand('copy')||prompt('コピー失敗—手動でコピー:',s);ta.remove()};try{navigator.clipboard.writeText(s).catch(fb)}catch(e){fb()}})()
```

## 2. ファイルに保存

各タブで[1]を実行して貯めたリストをプロンプトに貼り、`日付-ブラウザ名.md`(例: 2026-09-17-chrome.md)として保存。[File System Access API](https://developer.mozilla.org/docs/Web/API/File_System_API)対応環境では保存先を選び、書き込み完了後にタブを閉じようとする。キャンセル・空入力では中止し、保存先の選択や書き込みに失敗した場合はエラーを表示してタブを残す。プロンプト入力に時間がかかりユーザー操作の有効期限(約5秒)が切れた場合や、API非対応環境(Firefoxなど)では従来のダウンロードを開始し、約0.4秒後にタブを閉じようとする。この経路では保存完了を確認できない。スクリプトで開いていないタブはブラウザが閉じる要求を無視するため、通常タブは閉じないことが多い。

```javascript
javascript:(async()=>{const p=prompt('保存するリスト(- [title](url) 行):');if(p===null||!p.trim())return;const txt=p.trim()+'\n',d=new Date(),z=n=>String(n).padStart(2,'0'),dt=`${d.getFullYear()}-${z(d.getMonth()+1)}-${z(d.getDate())}`,ua=navigator.userAgent,b=/Edg\//.test(ua)?'edge':/OPR\//.test(ua)?'opera':/Firefox\//.test(ua)?'firefox':/Chrome\//.test(ua)?'chrome':/Safari\//.test(ua)?'safari':'browser',fn=`${dt}-${b}.md`,done=()=>{window.open('','_self');window.close()};if(typeof window.showSaveFilePicker==='function'){let h;try{h=await window.showSaveFilePicker({suggestedName:fn,types:[{description:'Markdown',accept:{'text/markdown':['.md']}}]})}catch(e){if(e.name==='AbortError')return;if(e.name!=='SecurityError'){alert('保存先を開けません: '+e.message);return}}if(h){try{const w=await h.createWritable();await w.write(txt);await w.close()}catch(e){alert('保存失敗: '+e.message);return}done();return}}const a=document.createElement('a');a.href=URL.createObjectURL(new Blob([txt],{type:'text/markdown'}));a.download=fn;document.body.appendChild(a);a.click();a.remove();setTimeout(()=>{URL.revokeObjectURL(a.href);done()},400)})()
```

## 3. 自動追記(クリップボード連結)

各タブで実行するだけで、現在のタブの1行を前回の出力に自動追記して書き戻す(前回のリストをプロンプトに貼る手間が不要)。初回は[クリップボード読み取り](https://developer.mozilla.org/docs/Web/API/Clipboard_API)の許可を求める。クリップボードの全行が `- [` で始まらない場合(無関係な内容)は追記せず新規扱い。読み取りに失敗したオリジン(http・許可拒否など)では[1]と同じ貼り付けプロンプトに自動切替。同じ行が既にあれば二重追加せずそのままコピー。行の形式・エスケープは[1]と同じ。

```javascript
javascript:(()=>{const t=document.title.replace(/\\/g,'\\\\').replace(/[\[\]]/g,'\\$&').replace(/\s+/g,' ').trim(),u=location.href.replace(/\(/g,'%'+'28').replace(/\)/g,'%'+'29'),l=`- [${t}](${u})`,fb=s=>{const ta=document.createElement('textarea');ta.value=s;ta.style.cssText='position:fixed;top:0;left:0;opacity:0';document.body.appendChild(ta);ta.select();document.execCommand('copy')||prompt('コピー失敗—手動でコピー:',s);ta.remove()},done=s=>{try{navigator.clipboard.writeText(s).catch(()=>fb(s))}catch(e){fb(s)}},onRead=prev=>{const p0=(prev||'').trim(),p=p0.split('\n').every(x=>x.startsWith('- ['))?p0:'';if(p.split('\n').includes(l))return done(p);done(p?p+'\n'+l:l)},viaPrompt=()=>{const p=prompt('前回のリストを貼って追記(空=新規):');if(p!==null)onRead(p)};try{navigator.clipboard.readText().then(onRead,viaPrompt)}catch(e){viaPrompt()}})()
```

## 4. Google翻訳(ページ内表示)

現在のページをGoogle翻訳の日本語版(translate.googドメイン)で同じタブ内に開く。http(s)以外のページと、既に翻訳ページ上では何もしない。ホストの `-` は `--` にエンコード(例: my-site.example.com → my--site-example-com.translate.goog)。検索クエリ・パス・ハッシュは保持(ポートは非対応)。

```javascript
javascript:(()=>{if(!/^https?:$/.test(location.protocol)||location.hostname.endsWith('.translate.goog'))return;const h=location.hostname.replace(/-/g,'--').replace(/\./g,'-'),u=new URL('https://'+h+'.translate.goog'+location.pathname);u.search=new URLSearchParams(location.search);u.searchParams.set('_x_tr_sl','auto');u.searchParams.set('_x_tr_tl','ja');u.searchParams.set('_x_tr_hl','ja');u.hash=location.hash;location.href=u})()
```

## 5. 決めたページをまとめて開く

実行のたびに決めたページセットをまとめて開く。スクリプト先頭の `d`(既定値)を普段使いのURL(空白/カンマ区切り)に書き換えて使う。プロンプトで都度編集も可。スキーム省略は `https://` を補い、`javascript:`/`data:` は無視。ポップアップブロックで開けなかった分はページ右上にパネル表示し、各URLのクリックで開ける(許可すれば次回から自動)。

```javascript
javascript:(()=>{const d='https://github.com https://youtube.com';const p=prompt('開くURL(空白/カンマ区切り):',d);if(p===null)return;const rest=[];for(const r of p.split(/[\s,]+/).filter(Boolean)){const u=/^[a-z][a-z\d+.-]*:/i.test(r)?r:'https://'+r;if(/^(javascript|data):/i.test(u))continue;const w=window.open(u,'_blank');if(w)w.opener=null;else rest.push(u)}if(!rest.length)return;const box=document.createElement('div');box.style.cssText='position:fixed;top:12px;right:12px;z-index:2147483647;background:#fff;color:#000;border:2px solid #333;padding:12px;font:14px sans-serif';box.textContent='ポップアップブロック——各URLをクリック:';for(const u of rest){const a=document.createElement('a');a.href=u;a.target='_blank';a.rel='noopener';a.textContent=u;a.style.cssText='display:block;margin:6px 0';box.appendChild(a)}const b=document.createElement('button');b.textContent='閉じる';b.style.cssText='display:block;margin-top:8px';b.onclick=()=>box.remove();box.appendChild(b);document.body.appendChild(box)})()
```

## 6. ページ内リンクを一括収集

現在のページの全リンク(`a[href]`)を走査し、Markdownリストとしてクリップボードへ一括コピー。同一URLの重複・ページ自身へのリンク・`href="#"`形式のページ内リンク・テキスト無し・`javascript:`/`mailto:`は除外。出現順。行の形式・エスケープは[1]と同じ。コピー不可環境では[1]と同じフォールバック。

```javascript
javascript:(()=>{const e=s=>s.replace(/\\/g,'\\\\').replace(/[\[\]]/g,'\\$&').replace(/\s+/g,' ').trim(),o=[],v=new Set(),pg=location.href.split('#')[0];for(const a of document.querySelectorAll('a[href]')){const u=a.href;if(!/^https?:/.test(u)||u.split('#')[0]===pg||v.has(u)||(a.getAttribute('href')||'').startsWith('#'))continue;const t=e(a.textContent);if(!t)continue;v.add(u);o.push(`- [${t}](${u.replace(/\(/g,'%'+'28').replace(/\)/g,'%'+'29')})`)}const s=o.join('\n');if(!s){alert('リンクが見つかりません');return}const fb=()=>{const ta=document.createElement('textarea');ta.value=s;ta.style.cssText='position:fixed;top:0;left:0;opacity:0';document.body.appendChild(ta);ta.select();document.execCommand('copy')||prompt('コピー失敗—手動でコピー:',s);ta.remove()};try{navigator.clipboard.writeText(s).catch(fb)}catch(x){fb()}})()
```

## 7. ページをMarkdownでコピー

現在のページ(選択範囲があればその部分のみ)を簡易Markdown化してクリップボードへ。見出し・段落・リンク・画像・強調・コードブロック・リスト・引用・表を対象に、script/style/nav/footer/aside/form等のノイズを除去。冒頭にタイトルとURLを付記。本文テキストの `\` `` ` `` `*` `_` `[` `]` はエスケープ(コード内は除く)、空白は連続を1つに整理(コードブロックを除く)。入れ子リストはインデントで保持。表は先頭行をヘッダーとして区切り行を補う。複雑なレイアウトは崩れる場合あり。`main`/`article` は最初の1つのみ対象で、非表示要素も含む。

```javascript
javascript:(()=>{const esc=s=>s.replace(/\\/g,'\\\\').replace(/[\[\]]/g,'\\$&').replace(/\s+/g,' ').trim(),pu=u=>u.replace(/\(/g,'%'+'28').replace(/\)/g,'%'+'29'),F='`'.repeat(3),root=document.createElement('div'),sel=getSelection();if(sel&&sel.rangeCount&&!sel.isCollapsed)root.appendChild(sel.getRangeAt(0).cloneContents());else root.appendChild((document.querySelector('main,article')||document.body).cloneNode(true));root.querySelectorAll('script,style,noscript,nav,footer,aside,form,svg,iframe,button').forEach(n=>n.remove());const conv=n=>{if(n.nodeType===3){const pp=n.parentElement;if(pp&&pp.closest('pre'))return n.textContent;const x=n.textContent.replace(/\s+/g,' ');return pp&&pp.closest('code')?x:x.replace(/[\\`*_\[\]]/g,'\\$&')}if(n.nodeType!==1)return '';const c=[...n.childNodes].map(conv).join(''),t=n.tagName;if(/^H[1-6]$/.test(t))return '\n\n'+'#'.repeat(+t[1])+' '+c.trim()+'\n\n';if(t==='P'||t==='DIV'||t==='SECTION'||t==='ARTICLE'||t==='MAIN'||t==='HEADER'||t==='FIGURE')return '\n\n'+c.trim()+'\n\n';if(t==='BR')return '\n';if(t==='HR')return '\n\n---\n\n';if(t==='A'){const h=n.href;return h&&/^https?:/.test(h)&&!(n.getAttribute('href')||'').startsWith('#')?`[${c.trim().replace(/\s+/g,' ')||h}](${pu(h)})`:c}if(t==='IMG'){const s=n.src;return s&&/^https?:/.test(s)?`![${esc(n.getAttribute('alt')||'')}](${pu(s)})`:''}if(t==='STRONG'||t==='B')return c.trim()?'**'+c.trim()+'**':c;if(t==='EM'||t==='I')return c.trim()?'*'+c.trim()+'*':c;if(t==='CODE')return n.parentElement&&n.parentElement.tagName==='PRE'?c:c.trim()?'`'+c.trim()+'`':c;if(t==='PRE')return '\n\n'+F+'\n'+c.replace(/^\n+|\s+$/g,'')+'\n'+F+'\n\n';if(t==='BLOCKQUOTE')return '\n\n'+c.trim().split('\n').map(l=>'> '+l).join('\n')+'\n\n';if(t==='UL'||t==='OL')return '\n\n'+[...n.children].map((li,i)=>{const m=t==='OL'?(i+1)+'. ':'- ';return m+conv(li).trim().replace(/\n{2,}/g,'\n').replace(/\n/g,'\n'+' '.repeat(m.length))}).join('\n')+'\n\n';if(t==='TR')return '\n|'+[...n.children].map(td=>conv(td).trim().replace(/\n+/g,' ').replace(/\|/g,'\\|')).join(' | ')+' |';if(t==='TABLE'){const r=c.trim().split('\n'),k=(n.querySelector('tr')||{children:[]}).children.length;if(k)r.splice(1,0,'|'+' --- |'.repeat(k));return '\n\n'+r.join('\n')+'\n\n'}return c};const body=conv(root).replace(/\n[ \t]+(?=\n)/g,'\n').replace(/\n{3,}/g,'\n\n').trim();if(!body){alert('コンテンツなし');return}const out='# '+document.title.replace(/\n/g,' ')+'\n\n'+location.href+'\n\n'+body+'\n';const fb=()=>{const ta=document.createElement('textarea');ta.value=out;ta.style.cssText='position:fixed;top:0;left:0;opacity:0';document.body.appendChild(ta);ta.select();document.execCommand('copy')||prompt('コピー失敗—手動でコピー:',out);ta.remove()};try{navigator.clipboard.writeText(out).catch(fb)}catch(x){fb()}})()
```

## 8. ページ状態レポート(デバッグ用)

ページの基本情報(タイトル・URL・UA・viewport・画面サイズ・devicePixelRatio・日時・選択範囲)とフォーム入力値をMarkdownレポート化してクリップボードへ。[Network Information API](https://developer.mozilla.org/docs/Web/API/Network_Information_API)対応環境(Chrome系のみ)では推定通信品質も記載する(`4g`などの値は実際の通信方式を示すものではない)。パスワード・ファイル・hidden入力・`autocomplete="cc-*"`(カード情報)の値は除外するが、それ以外の入力値と選択範囲(先頭500文字)は出力されるため、共有前に内容を確認すること。エージェントへのバグ報告・状況共有用。実行前のコンソールエラーは取得できない(ブックマークレットからは過去のログへアクセス不可)。

```javascript
javascript:(()=>{const L=[],d=document,P=k=>L.push(k);P('# '+d.title.replace(/\n/g,' '));P('- URL: '+location.href);P('- viewport: '+window.innerWidth+'x'+window.innerHeight);P('- 画面: '+screen.width+'x'+screen.height+' @'+window.devicePixelRatio+'x');const cn=navigator.connection;if(cn&&cn.effectiveType)P('- 回線: '+cn.effectiveType);P('- UA: '+navigator.userAgent);P('- 日時: '+new Date().toLocaleString());const s=d.getSelection();if(s&&s.rangeCount&&!s.isCollapsed)P('- 選択: '+s.toString().replace(/\s+/g,' ').trim().slice(0,500));const fs=[...d.querySelectorAll('input,select,textarea')].filter(e=>e.type!=='hidden'&&e.type!=='password'&&e.type!=='file'&&!/(^|\s)cc-/i.test(e.getAttribute('autocomplete')||''));if(fs.length){P('');P('## フォーム');for(const e of fs){const n=e.id||e.name||e.type;const v=(e.type==='checkbox'||e.type==='radio')?(e.checked?'on':'off'):String(e.value||'').slice(0,200);P(`- ${n}(${e.type}): ${v}`)}}const out=L.join('\n')+'\n';const fb=()=>{const ta=document.createElement('textarea');ta.value=out;ta.style.cssText='position:fixed;top:0;left:0;opacity:0';document.body.appendChild(ta);ta.select();document.execCommand('copy')||prompt('コピー失敗—手動でコピー:',out);ta.remove()};try{navigator.clipboard.writeText(out).catch(fb)}catch(x){fb()}})()
```

## 9. 要素消去モード

起動するとカーソルが十字になり、ホバー中の要素を赤枠表示。クリックでその要素を削除する(選択範囲のスクリーンショットやコピーの前掃除用)。再実行またはEscで終了。削除は再読み込みで元に戻る。ページのCSPによって赤枠などの表示が制限される場合がある。変更はそのページの表示のみに影響。`click`のみ抑止するため、mousedown等で動作するUIは反応する場合がある。

```javascript
javascript:(()=>{if(window.__erx){window.__erx();return}const st=document.createElement('style');st.textContent='html{cursor:crosshair!important}.__erx{outline:3px solid #e53935!important;outline-offset:-3px!important}';document.head.appendChild(st);const b=document.createElement('div');b.id='__erb';b.textContent='消去モード: クリックで要素削除 / Escで終了';b.style.cssText='position:fixed;left:8px;bottom:8px;z-index:2147483647;background:#111;color:#fff;padding:4px 10px;border-radius:4px;font:12px sans-serif';document.body.appendChild(b);let cur=null;const ov=e=>{if(e.target.closest&&e.target.closest('#__erb'))return;if(cur)cur.classList.remove('__erx');cur=e.target;cur.classList.add('__erx')};const cl=e=>{const el=e.target;if(el.closest&&el.closest('#__erb'))return;if(el===document.documentElement||el===document.body)return;e.preventDefault();e.stopPropagation();el.remove();if(cur){cur.classList.remove('__erx');cur=null}};const key=e=>{if(e.key==='Escape')exit()};function exit(){document.removeEventListener('mouseover',ov,true);document.removeEventListener('click',cl,true);document.removeEventListener('keydown',key,true);if(cur)cur.classList.remove('__erx');st.remove();b.remove();delete window.__erx}document.addEventListener('mouseover',ov,true);document.addEventListener('click',cl,true);document.addEventListener('keydown',key,true);window.__erx=exit})()
```

## 10. 全タブを一括でリスト化(書き出しHTMLから)

ブックマークレットから他のタブを列挙するAPIは存在しないため、ブラウザ標準の「全タブをブックマーク」で作ったフォルダを経由する。手順: (1) 全タブをまとめて1フォルダにブックマーク(Chrome・FirefoxともCmd+Shift+D) (2) ブックマークマネージャ(Chrome)/ライブラリ(Firefox)からブックマークをHTMLで書き出す (3) 任意のページでこのブックマークレットを実行し、書き出したHTMLを選択 (4) フォルダ名(完全一致を優先、次に番号、次に部分一致・空=全ブックマーク)を入力すると、そのフォルダ内の全リンク(下層フォルダ含む・出現順)を`- [title](url)`行としてクリップボードへ出力。`javascript:`のブックマーク(ブックマークレット)は除外、それ以外のスキームは残る(chrome://等)。書き出しHTMLにはブックマーク全体が入るため、普段はフォルダ名での絞り込みを推奨。行の形式・エスケープは[1]と同じ。コピー不可環境では[1]と同じフォールバック。

```javascript
javascript:(async()=>{const e=s=>s.replace(/\\/g,'\\\\').replace(/[\[\]]/g,'\\$&').replace(/\s+/g,' ').trim(),pu=u=>u.replace(/\(/g,'%'+'28').replace(/\)/g,'%'+'29'),i=document.createElement('input');i.type='file';i.accept='.html,text/html';i.style.display='none';i.addEventListener('cancel',()=>i.remove());i.onchange=async()=>{let s='';try{const doc=new DOMParser().parseFromString(await i.files[0].text(),'text/html'),fs=[...doc.querySelectorAll('h3')],p=prompt('フォルダ名または番号(部分一致・空=全ブックマーク):\n'+fs.map((h,k)=>k+': '+h.textContent.trim()).join('\n'),'');if(p!==null){let src=doc;if(p){const ex=fs.filter(h=>h.textContent.trim()===p),hit=ex.length?ex:/^\d+$/.test(p)&&fs[+p]?[fs[+p]]:fs.filter(h=>h.textContent.includes(p)),d=hit.length===1&&hit[0].closest('dt'),dl=d?d.querySelector('dl')||(d.nextElementSibling&&d.nextElementSibling.tagName==='DL'?d.nextElementSibling:0):0;src=dl||0;if(!src)alert(hit.length>1?'複数一致—フォルダ名を具体化してください:\n'+hit.map(h=>h.textContent).join('\n'):'フォルダが見つかりません')}if(src)s=[...src.querySelectorAll('a')].filter(a=>!/^javascript:/i.test(a.getAttribute('href')||'')).map(a=>`- [${e(a.textContent)}](${pu(a.getAttribute('href')||'')})`).join('\n')}}catch(x){alert('読み込み失敗: '+x.message)}finally{i.remove()}if(!s)return;const fb=()=>{const ta=document.createElement('textarea');ta.value=s;ta.style.cssText='position:fixed;top:0;left:0;opacity:0';document.body.appendChild(ta);ta.select();document.execCommand('copy')||prompt('コピー失敗—手動でコピー:',s);ta.remove()};try{navigator.clipboard.writeText(s).catch(fb)}catch(x){fb()}};document.body.appendChild(i);i.click()})()
```
