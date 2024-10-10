from PIL import Image


filename = 'bears_copy.jpg'
filepath = f"./{filename}"

file_out = 'bears2.jpg'
file_out_path = f"./{file_out}"


#Manual version with formula

# Load the original image, and get its size and color mode.
orig_image = Image.open(filepath)
width, height = orig_image.size
mode = orig_image.mode

# Load all pixels from the image.
orig_pixel_map = orig_image.load()

# Create a new image matching the original image's color mode, and size.
#   Load all the pixels from this new image as well.
new_image = Image.new("L", (width, height))
new_pixel_map = new_image.load()

for x in range(width):
    for y in range(height):
        r, g, b = orig_pixel_map[x, y]
        grayscale_value = int(0.2989 * r + 0.5870 * g + 0.1140 * b)
        new_pixel_map[x, y] = grayscale_value

new_image.save(file_out_path)


# method version

orig_image = Image.open(filepath)

new_image = orig_image.convert("L")

new_image.save(file_out_path)


# I used both versions of this because despite working in VSC,
# Codio refused to convert the image to grayscale and I couldn't 
# figure out what was wrong.
# Then it suddenly decided to work. I hadn't changed anything.

# I truly despise Codio. 