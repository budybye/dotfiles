# Album Artwork Manager

A skill for managing album artwork in music files.

## Description

This skill specializes in embedding, extracting, and managing album artwork in audio files. It handles various image formats and can work with online sources to find appropriate album covers.

## Capabilities

- Embed album artwork into audio files
- Extract existing artwork from audio files
- Search for album artwork from online databases
- Convert images to appropriate formats and sizes
- Handle multiple image formats (JPEG, PNG, etc.)

## Usage Examples

- "Add album artwork to my song.mp3 file"
- "Extract the album cover from this music file"
- "Find and embed the album artwork for this album"
- "Resize album artwork to 500x500 pixels"

## Requirements

- eyeD3 or similar tagging tool installed
- Python Pillow library for image processing
- Requests library for online searches

### Installation Instructions
- **eyeD3**: `pip install eyed3`
- **Pillow**: `pip install Pillow`
- **requests**: `pip install requests`

## Implementation Notes

Use appropriate tools to embed artwork without modifying audio data. Ensure images are properly formatted and sized for optimal compatibility.

### Tool Selection Guide
- **eyeD3**: Best for embedding artwork in MP3 files
- **mutagen**: Good for Python-based artwork handling across formats
- **Pillow**: Essential for image processing and conversion

### Python Examples
```python
import eyed3
from PIL import Image
import requests
from io import BytesIO

def embed_artwork(audio_file_path, image_path):
    """Embed artwork into an audio file"""
    audiofile = eyed3.load(audio_file_path)
    if audiofile.tag is None:
        audiofile.initTag()
    
    # Resize image if needed
    img = Image.open(image_path)
    img = img.resize((500, 500))  # Standard size
    
    # Save resized image to bytes
    img_bytes = BytesIO()
    img.save(img_bytes, format='JPEG')
    
    # Embed artwork
    audiofile.tag.images.set(3, img_bytes.getvalue(), "image/jpeg")
    audiofile.tag.save()

def extract_artwork(audio_file_path, output_path):
    """Extract artwork from an audio file"""
    audiofile = eyed3.load(audio_file_path)
    if audiofile.tag is not None and audiofile.tag.images:
        artwork = audiofile.tag.images[0]
        with open(output_path, 'wb') as img_file:
            img_file.write(artwork.image_data)
```

### Error Handling
- Check if audio file exists before processing
- Verify image file validity
- Handle network errors when searching online
- Implement try/except blocks for file operations