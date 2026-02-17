import os
import re

def fix_codebase(directory):
    package_name = 'craftconnect'
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    modified = False
                    
                    # 1. Fix missing app_constants.dart
                    if re.search(r'\b(AppSpacing|AppRadius|AppDecorations)\b', content):
                        if 'app_constants.dart' not in content:
                            import_stmt = f"import 'package:{package_name}/config/app_constants.dart';"
                            # Insert after last import
                            lines = content.splitlines()
                            import_indices = [i for i, l in enumerate(lines) if l.strip().startswith('import ')]
                            if import_indices:
                                lines.insert(max(import_indices) + 1, import_stmt)
                            else:
                                lines.insert(0, import_stmt)
                            content = '\n'.join(lines)
                            modified = True
                            print(f"Added app_constants import to {filepath}")

                    # 2. Fix missing theme.dart (just in case)
                    if re.search(r'\bAppTheme\b', content):
                        if 'theme.dart' not in content:
                            import_stmt = f"import 'package:{package_name}/config/theme.dart';"
                            lines = content.splitlines()
                            import_indices = [i for i, l in enumerate(lines) if l.strip().startswith('import ')]
                            if import_indices:
                                lines.insert(max(import_indices) + 1, import_stmt)
                            else:
                                lines.insert(0, import_stmt)
                            content = '\n'.join(lines)
                            modified = True
                            print(f"Added theme import to {filepath}")

                    # 3. Fix deprecated withOpacity to withValues(alpha: ...)
                    # Matches .withOpacity(0.1) -> .withValues(alpha: 0.1)
                    # Matches .withOpacity(alpha: 0.1) -> .withValues(alpha: 0.1)
                    new_content = re.sub(r'\.withOpacity\(\s*([0-9.]+)\s*\)', r'.withValues(alpha: \1)', content)
                    new_content = re.sub(r'\.withOpacity\(\s*alpha:\s*([0-9.]+)\s*\)', r'.withValues(alpha: \1)', new_content)
                    
                    if new_content != content:
                        content = new_content
                        modified = True
                        print(f"Fixed withOpacity in {filepath}")

                    if modified:
                        with open(filepath, 'w', encoding='utf-8') as f:
                            f.write(content)

                except Exception as e:
                    print(f"Error processing {filepath}: {e}")

if __name__ == '__main__':
    fix_codebase('lib')
