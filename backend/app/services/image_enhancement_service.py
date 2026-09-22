from pathlib import Path
from uuid import uuid4
from PIL import Image, ImageEnhance, ImageFilter, ImageOps

ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp"}
MAX_IMAGE_BYTES = 10 * 1024 * 1024


def enhance_product_photo(source: Path, destination_dir: Path) -> str:
    """Create a marketplace-ready enhanced copy without modifying the original image."""
    destination_dir.mkdir(parents=True, exist_ok=True)
    with Image.open(source) as original:
        image = ImageOps.exif_transpose(original).convert("RGB")
        image.thumbnail((1800, 1800), Image.Resampling.LANCZOS)
        image = ImageEnhance.Contrast(image).enhance(1.12)
        image = ImageEnhance.Color(image).enhance(1.08)
        image = ImageEnhance.Brightness(image).enhance(1.04)
        image = image.filter(ImageFilter.UnsharpMask(radius=1.2, percent=115, threshold=3))
        output_name = f"{uuid4().hex}.jpg"
        output_path = destination_dir / output_name
        image.save(output_path, "JPEG", quality=92, optimize=True)
    return output_name
