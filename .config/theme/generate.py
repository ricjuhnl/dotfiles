import re
import os

# Paths
THEME_DIR = os.path.dirname(os.path.abspath(__file__))
COLORS_CSS = os.path.join(THEME_DIR, 'colors.css')
GENERATED_DIR = os.path.join(THEME_DIR, 'generated')

# Mappings for Kitty
KITTY_MAPPING = {
    'foreground': 'text',
    'background': 'base',
    'selection_foreground': 'base',
    'selection_background': 'rosewater',
    'cursor': 'rosewater',
    'cursor_text_color': 'base',
    'url_color': 'rosewater',
    'active_border_color': 'lavender',
    'inactive_border_color': 'overlay0',
    'bell_border_color': 'yellow',
    'wayland_titlebar_color': 'system',
    'macos_titlebar_color': 'system',
    'active_tab_foreground': 'crust',
    'active_tab_background': 'mauve',
    'inactive_tab_foreground': 'text',
    'inactive_tab_background': 'mantle',
    'tab_bar_background': 'crust',
    'mark1_foreground': 'base',
    'mark1_background': 'lavender',
    'mark2_foreground': 'base',
    'mark2_background': 'mauve',
    'mark3_foreground': 'base',
    'mark3_background': 'sapphire',
    'color0': 'surface1',
    'color8': 'surface2',
    'color1': 'red',
    'color9': 'red',
    'color2': 'green',
    'color10': 'green',
    'color3': 'yellow',
    'color11': 'yellow',
    'color4': 'blue',
    'color12': 'blue',
    'color5': 'pink',
    'color13': 'pink',
    'color6': 'teal',
    'color14': 'teal',
    'color7': 'subtext1',
    'color15': 'subtext0'
}

def parse_colors(css_file):
    colors = {}
    with open(css_file, 'r') as f:
        for line in f:
            match = re.search(r'@define-color\s+(\w+)\s+(#[0-9a-fA-F]{6});', line)
            if match:
                name, hex_val = match.groups()
                colors[name] = hex_val
    return colors

def generate_hypr(colors):
    content = ""
    for name, hex_val in colors.items():
        hex_no_hash = hex_val[1:]
        content += f"${name} = rgb({hex_no_hash})\n"
        content += f"${name}Alpha = {hex_no_hash}\n\n"
    
    with open(os.path.join(GENERATED_DIR, 'hypr.conf'), 'w') as f:
        f.write(content)

def generate_kitty(colors):
    content = "# Generated kitty theme\n\n"
    for key, value in KITTY_MAPPING.items():
        if value == 'system':
            content += f"{key} system\n"
        elif value in colors:
            content += f"{key} {colors[value]}\n"
        else:
            # Fallback or error? For now, skip if not found
            print(f"Warning: Color '{value}' not found for kitty key '{key}'")
    
    with open(os.path.join(GENERATED_DIR, 'kitty.conf'), 'w') as f:
        f.write(content)

def generate_rofi(colors):
    content = "* {\n"
    for name, hex_val in colors.items():
        content += f"    {name}: {hex_val};\n"
    content += "}\n"
    
    with open(os.path.join(GENERATED_DIR, 'rofi.rasi'), 'w') as f:
        f.write(content)

def main():
    if not os.path.exists(GENERATED_DIR):
        os.makedirs(GENERATED_DIR)
        
    colors = parse_colors(COLORS_CSS)
    
    generate_hypr(colors)
    generate_kitty(colors)
    generate_rofi(colors)
    
    print("Configuration files generated successfully.")

if __name__ == "__main__":
    main()
