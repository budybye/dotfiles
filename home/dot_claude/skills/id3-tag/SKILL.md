# ID3 Tag Editor

A skill for automatically searching, retrieving, and editing ID3 tags in music files. (Note: Album artwork and lyrics are handled by separate specialized skills.)

## Description

This skill helps users manage core metadata in audio files by:
- Searching for ID3 tags in music files
- Retrieving existing tag information (title, artist, album, year, genre, track number, etc.)
- Editing and updating tag information
- Adding missing tags to files

Note: Album artwork and lyrics are handled by separate specialized skills.

## Capabilities

- Read ID3 v1, v2.3, and v2.4 tags
- Extract metadata including title, artist, album, track number, year, genre, and album artwork
- Modify existing tags or add new ones
- Handle various audio formats (MP3, FLAC, OGG, etc.)
- Batch process multiple files

## Usage Examples

- "Update the artist name in my song.mp3 file"
- "Show me the ID3 tags for all MP3 files in this directory"
- "Batch update the genre for all songs in this folder"
- "Set the track number for this song to 5"

## Requirements

- eyeD3 or similar tagging tool installed
- ffmpeg for format conversion if needed
- Python mutagen library for advanced tag manipulation

### Installation Instructions
- **eyeD3**: `pip install eyed3`
- **ffmpeg**: 
  - macOS: `brew install ffmpeg`
  - Ubuntu: `sudo apt install ffmpeg`
  - Windows: Download from https://ffmpeg.org/download.html
- **mutagen**: `pip install mutagen`

## Implementation Notes

Use appropriate command-line tools or Python libraries to manipulate ID3 tags without modifying the audio data. Ensure backups are made before making changes to files.

### Tool Selection Guide
- **eyeD3**: Best for MP3 files with ID3 tags, command-line focused
- **mutagen**: Best for Python scripts, supports multiple formats (MP3, FLAC, OGG)
- **ffmpeg**: Best for format conversion or complex audio processing

### Basic Commands
- Reading tags: `eyeD3 song.mp3`
- Setting tags: `eyeD3 --artist="New Artist" --album="New Album" song.mp3`
- Batch processing: `eyeD3 --genre=Rock *.mp3`

### Python Examples
```python
from mutagen.id3 import ID3, TIT2, TPE1, TALB
from mutagen.mp3 import MP3
from mutagen.flac import FLAC
from mutagen.oggvorbis import OggVorbis

def update_tags(filepath, title=None, artist=None, album=None):
    # Handle different file formats
    if filepath.lower().endswith('.mp3'):
        audio = MP3(filepath, ID3=ID3)
        if title:
            audio.tags.add(TIT2(encoding=3, text=title))
        if artist:
            audio.tags.add(TPE1(encoding=3, text=artist))
        if album:
            audio.tags.add(TALB(encoding=3, text=album))
        audio.save()
    elif filepath.lower().endswith('.flac'):
        audio = FLAC(filepath)
        if title:
            audio['title'] = title
        if artist:
            audio['artist'] = artist
        if album:
            audio['album'] = album
        audio.save()
    elif filepath.lower().endswith('.ogg'):
        audio = OggVorbis(filepath)
        if title:
            audio['title'] = title
        if artist:
            audio['artist'] = artist
        if album:
            audio['album'] = album
        audio.save()

# Batch processing example
def batch_update_tags(file_list, genre=None):
    for filepath in file_list:
        try:
            if filepath.lower().endswith('.mp3'):
                audio = MP3(filepath, ID3=ID3)
                if genre:
                    from mutagen.id3 import TCON
                    audio.tags.add(TCON(encoding=3, text=genre))
                audio.save()
            # Add similar handling for other formats
        except Exception as e:
            print(f"Error processing {filepath}: {e}")
```

### Error Handling
- Always check if files exist before processing
- Validate tag values before writing
- Implement try/except blocks for file operations
- Log errors for troubleshooting