import os
import re

files_with_errors = [
    "lib/screens/artisan/inventory_management_screen.dart",
    "lib/screens/artisan/order_details_screen.dart",
    "lib/screens/artisan/orders_screen.dart",
    "lib/screens/artisan/settings_screen.dart",
    "lib/screens/artisan/shop_analytics_screen.dart",
    "lib/screens/auth/login_screen.dart",
    "lib/screens/auth/register_screen.dart",
    "lib/screens/buyer/account_screen.dart",
    "lib/screens/buyer/apply_coupon_screen.dart",
    "lib/screens/buyer/cart_checkout_screen.dart",
    "lib/screens/buyer/category_products_screen.dart",
    "lib/screens/buyer/chat_list_screen.dart",
    "lib/screens/buyer/chat_room_screen.dart",
    "lib/screens/buyer/edit_profile_screen.dart",
    "lib/screens/buyer/help_support_screen.dart",
    "lib/screens/buyer/order_confirmation_screen.dart",
    "lib/screens/buyer/payment_screen.dart",
    "lib/screens/buyer/product_compare_screen.dart",
    "lib/screens/buyer/product_page.dart",
    "lib/screens/buyer/recently_viewed_screen.dart",
]

def fix_files():
    package_name = 'craftconnect'
    for rel_path in files_with_errors:
        filepath = os.path.join(os.getcwd(), rel_path.replace('/', os.sep))
        if not os.path.exists(filepath):
            print(f"File not found: {filepath}")
            continue
            
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            modified = False
            
            # 1. Add app_constants import if missing
            if 'app_constants.dart' not in content:
                import_stmt = f"import 'package:{package_name}/config/app_constants.dart';"
                lines = content.splitlines()
                import_indices = [i for i, l in enumerate(lines) if l.strip().startswith('import ')]
                if import_indices:
                    lines.insert(max(import_indices) + 1, import_stmt)
                else:
                    lines.insert(0, import_stmt)
                content = '\n'.join(lines)
                modified = True
                print(f"Added app_constants import to {rel_path}")

            # 2. Fix withOpacity
            new_content = re.sub(r'\.withOpacity\(\s*([0-9.]+)\s*\)', r'.withValues(alpha: \1)', content)
            new_content = re.sub(r'\.withOpacity\(\s*alpha:\s*([0-9.]+)\s*\)', r'.withValues(alpha: \1)', new_content)
            
            if new_content != content:
                content = new_content
                modified = True
                print(f"Fixed withOpacity in {rel_path}")

            if modified:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
        except Exception as e:
            print(f"Error fixing {rel_path}: {e}")

if __name__ == '__main__':
    fix_files()
