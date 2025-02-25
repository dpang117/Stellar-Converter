import os

REQUIRED_ICONS = {
    # Cryptocurrencies
    'BTC', 'ETH', 'XLM', 'BNB', 'XRP', 'ADA', 'SOL', 'MATIC', 'AVAX', 'DOT',
    'UNI', 'BCH', 'LINK', 'LTC', 'ATOM', 'EOS', 'DOGE', 'XMR', 'ALGO', 'XTZ',
    
    # DeFi & Web3 Tokens
    'COMP', 'AAVE', 'MKR', 'SNX', 'YFI', 'BAT', 'CRV', 'GRT', 'SUSHI', '1INCH',
    'ENJ', 'SAND', 'MANA', 'AXS', 'FTM', 'VET', 'ONE', 'FIL', 'NEAR', 'THETA',
    
    # Stablecoins
    'USDT', 'USDC', 'BUSD', 'DAI', 'UST', 'SUSD', 'TUSD', 'HUSD', 'USDP', 'GUSD',
    'RSR', 'MIM', 'FRAX', 'OUSD', 'LUSD', 'XSGD', 'EURS', 'EURT', 'USDX', 'USDN'
}

def fix_svg_file(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        needs_fixing = False
        
        # Check for filter elements
        if '<filter' in content or '<defs>' in content:
            print(f"Found filter in: {file_path}")
            needs_fixing = True
            
            # Remove filter sections
            while '<defs>' in content:
                start = content.find('<defs>')
                end = content.find('</defs>') + 7
                content = content[:start] + content[end:]
            
            # Remove filter attributes and fix colors
            content = content.replace(' filter="url(#a)"', '')
            content = content.replace(' filter="url(#filter0_d)"', '')
            content = content.replace('fill="#000"', 'fill="#FFFFFF"')
            content = content.replace('fill="black"', 'fill="#FFFFFF"')
            
            # Fix any remaining filter references
            while 'filter="url(#' in content:
                start = content.find('filter="url(#')
                end = content.find(')"', start) + 2
                content = content[:start] + content[end:]
        
        # Ensure proper SVG structure
        if not content.startswith('<svg'):
            print(f"Fixing SVG structure in: {file_path}")
            needs_fixing = True
            content = f'<svg width="32" height="32" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">\n{content}</svg>'
        
        if needs_fixing:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Fixed: {file_path}")
            
    except Exception as e:
        print(f"Error processing {file_path}: {str(e)}")

def verify_icons():
    directory = 'assets/crypto_icons'
    existing_icons = set()
    
    if not os.path.exists(directory):
        print(f"Directory not found: {directory}")
        return
    
    # Get list of existing icons
    for filename in os.listdir(directory):
        if filename.endswith('.svg'):
            icon_name = filename[:-4].upper()  # Remove .svg and convert to uppercase
            existing_icons.add(icon_name)
            try:
                fix_svg_file(os.path.join(directory, filename))
            except Exception as e:
                print(f"Failed to process {filename}: {str(e)}")
    
    # Check for missing icons
    missing_icons = REQUIRED_ICONS - existing_icons
    extra_icons = existing_icons - REQUIRED_ICONS
    
    print("\n=== Icon Status ===")
    print(f"Total required icons: {len(REQUIRED_ICONS)}")
    print(f"Existing icons: {len(existing_icons)}")
    
    if missing_icons:
        print("\nMissing icons:")
        for icon in sorted(missing_icons):
            print(f"- {icon}")
    
    if extra_icons:
        print("\nExtra icons found:")
        for icon in sorted(extra_icons):
            print(f"- {icon}")

if __name__ == '__main__':
    print("Starting icon verification...")
    verify_icons()
    print("\nFinished verification")