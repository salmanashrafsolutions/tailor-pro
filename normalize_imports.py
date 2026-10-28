import os, re

base = r'd:\TAILER MOBILE APP\lib'

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content
    # Replace any relative imports within features or core
    content = re.sub(r"import\s+['\"](\.\./)+models/([^'\"]+)['\"];", r"import 'package:tailor_pro/features/FEATURE_NAME/models/\2';", content)
    content = re.sub(r"import\s+['\"](\.\./)+providers/([^'\"]+)['\"];", r"import 'package:tailor_pro/features/FEATURE_NAME/providers/\2';", content)
    
    # Specific targeted replacements:
    replacements = [
        # Business
        ("import '../providers/business_provider.dart';", "import 'package:tailor_pro/features/business/providers/business_provider.dart';"),
        ("import '../../business/providers/business_provider.dart';", "import 'package:tailor_pro/features/business/providers/business_provider.dart';"),
        
        # Customers
        ("import '../models/customer_model.dart';", "import 'package:tailor_pro/features/customers/models/customer_model.dart';"),
        ("import '../providers/customer_provider.dart';", "import 'package:tailor_pro/features/customers/providers/customer_provider.dart';"),
        ("import 'customer_detail_screen.dart';", "import 'package:tailor_pro/features/customers/presentation/screens/customer_detail_screen.dart';"),
        ("import 'customer_edit_screen.dart';", "import 'package:tailor_pro/features/customers/presentation/screens/customer_edit_screen.dart';"),
        ("import 'customer_list_screen.dart';", "import 'package:tailor_pro/features/customers/presentation/screens/customer_list_screen.dart';"),

        # Measurements
        ("import '../../models/measurement_model.dart';", "import 'package:tailor_pro/features/measurements/models/measurement_model.dart';"),
        ("import '../models/measurement_model.dart';", "import 'package:tailor_pro/features/measurements/models/measurement_model.dart';"),
        ("import '../widgets/custom_option_dialog.dart';", "import 'package:tailor_pro/features/measurements/presentation/widgets/custom_option_dialog.dart';"),
        ("import 'sketch_canvas_screen.dart';", "import 'package:tailor_pro/features/measurements/presentation/screens/sketch_canvas_screen.dart';"),
        ("import 'measurement_input_screen.dart';", "import 'package:tailor_pro/features/measurements/presentation/screens/measurement_input_screen.dart';"),

        # Orders
        ("import '../../models/order_model.dart';", "import 'package:tailor_pro/features/orders/models/order_model.dart';"),
        ("import '../models/order_model.dart';", "import 'package:tailor_pro/features/orders/models/order_model.dart';"),
        ("import '../../providers/order_provider.dart';", "import 'package:tailor_pro/features/orders/providers/order_provider.dart';"),
        ("import '../providers/order_provider.dart';", "import 'package:tailor_pro/features/orders/providers/order_provider.dart';"),
        ("import 'order_create_screen.dart';", "import 'package:tailor_pro/features/orders/presentation/screens/order_create_screen.dart';"),
        ("import 'order_detail_screen.dart';", "import 'package:tailor_pro/features/orders/presentation/screens/order_detail_screen.dart';"),
        ("import 'order_list_screen.dart';", "import 'package:tailor_pro/features/orders/presentation/screens/order_list_screen.dart';"),
        ("import 'delivery_calendar_screen.dart';", "import 'package:tailor_pro/features/orders/presentation/screens/delivery_calendar_screen.dart';"),

        # Billing
        ("import '../../models/ledger_model.dart';", "import 'package:tailor_pro/features/billing/models/ledger_model.dart';"),
        ("import '../models/ledger_model.dart';", "import 'package:tailor_pro/features/billing/models/ledger_model.dart';"),
        ("import 'customer_ledger_screen.dart';", "import 'package:tailor_pro/features/billing/presentation/screens/customer_ledger_screen.dart';"),
        ("import 'dues_list_screen.dart';", "import 'package:tailor_pro/features/billing/presentation/screens/dues_list_screen.dart';"),
        ("import 'print_preview_screen.dart';", "import 'package:tailor_pro/features/billing/presentation/screens/print_preview_screen.dart';"),

        # Expenses
        ("import '../models/expense_model.dart';", "import 'package:tailor_pro/features/expenses/models/expense_model.dart';"),
        ("import 'expense_list_screen.dart';", "import 'package:tailor_pro/features/expenses/presentation/screens/expense_list_screen.dart';"),

        # Core
        ("import '../utils/fraction_formatter.dart';", "import 'package:tailor_pro/core/utils/fraction_formatter.dart';"),
    ]

    for old, new in replacements:
        content = content.replace(old, new)

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed: {os.path.basename(filepath)}")

for root, _, files in os.walk(base):
    for f in files:
        if f.endswith('.dart'):
            fix_file(os.path.join(root, f))

print("Comprehensive import normalization done!")

