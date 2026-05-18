# Testing Report

## Test Case 1: Delete Expenses / Income

Module Name: User Dashboard

Test Title: Delete expenses / income

Description: Validate deletion with confirmation dialog.

Test Executed by: Samuel

Test Execution date: 25-3-2026

| Step | Test Steps | Expected Result | Actual Result | Status (Pass/Fail) |
| --- | --- | --- | --- | --- |
| 1 | Press delete icon | Confirmation message should appear | Confirmation message displayed | Pass |
| 2 | Click "Cancel" | Deletion should be cancelled | Deletion cancelled | Pass |
| 3 | Press delete icon | Confirmation message should appear | Confirmation message displayed | Pass |
| 4 | Click "Yes" | Expense / income should be deleted successfully | Deleted successfully | Pass |

Post-conditions: Deleted only after confirmation.

## Test Case 2: Category Suggestions In Home Search

Module Name: Autocomplete & Suggestions

Test Title: Category Suggestions in Home Search

Description: Validate that the system provides autocomplete suggestions for expense categories in the Home page search bar.

Test Executed by: Samuel

Test Execution date: 12-5-2026

| Step | Test Steps | Expected Result | Actual Result | Status (Pass/Fail) | Notes |
| --- | --- | --- | --- | --- | --- |
| 1 | Open Home page | Search bar should be visible | Visible | Pass |  |
| 2 | Type "f" | Suggestion "Food" should appear | Shown | Pass |  |
| 3 | Type partial text, e.g. "tr" | Suggestion "Transport" should appear | Shown | Pass |  |
| 4 | Type full category name | Exact category should be selected/displayed | Selected | Pass |  |
| 5 | Enter invalid text, e.g. "xyz" | No matching category should be found | No result shown | Pass |  |

Post-conditions: User can quickly select expense categories using autocomplete suggestions on Home page.

## Test Case 3: Add Expense Validation

Module Name: User Dashboard

Test Title: Add expense

Description: Validate expense amount before adding.

Test Executed by: Samuel

Test Execution date: 25-3-2026

| Step | Test Steps | Expected Result | Actual Result | Status (Pass/Fail) |
| --- | --- | --- | --- | --- |
| 1 | Press Add button | Expense should not be added | Not added | Pass |
| 2 | Enter budget amount = 0 | Show error "Please enter a valid amount" | Error shown | Pass |
| 3 | Enter valid budget amount | Expense added | Expense added | Pass |
| 4 | Enter amount with leading zero | Show error "Amount cannot start with leading zeros" | Error shown | Pass |

Post-conditions: Invalid expense is rejected.

## Test Case 4: Add Income Validation

Module Name: User Dashboard

Test Title: Add Income

Description: Validate income amount before adding.

Test Executed by: Samuel

Test Execution date: 25-3-2026

| Step | Test Steps | Expected Result | Actual Result | Status (Pass/Fail) |
| --- | --- | --- | --- | --- |
| 1 | Press Add button | Income should not be added | Not added | Pass |
| 2 | Enter income amount = 0 | Show error "Please enter a valid amount" | Error shown | Pass |
| 3 | Enter valid income amount | Income added | Income added | Pass |
| 4 | Enter amount with leading zero | Show error "Amount cannot start with leading zeros" | Error shown | Pass |

Post-conditions: Invalid income is rejected.

## Test Case 5: Search Transactions

Module Name: Report

Test Title: Search Transactions

Description: Verify search behavior in detailed statement.

Test Executed by: Samuel

Test Execution date: 25-3-2026

| Step | Test Steps | Expected Result | Actual Result | Status (Pass/Fail) |
| --- | --- | --- | --- | --- |
| 1 | Press Search without input | Show "No transactions found" | Message shown | Pass |
| 2 | Do not perform search | Results should not appear | No results shown | Pass |
| 3 | Enter dates and press search | Result appears | Result shown | Pass |
| 4 | Sort by latest | Show latest | Latest shown | Pass |
| 5 | Sort by oldest | Show oldest | Oldest shown | Pass |

Post-conditions: System shows results only after valid search.

## Test Case 6: Contextual Budget Reminder

Module Name: Notifications

Test Title: Contextual reminders when budget is close to limit

Description: Validate that the system sends a notification when the budget is close to its limit.

Test Executed by: Samuel

Test Execution date: 25-3-2026

| Step | Test Steps | Expected Result | Actual Result | Status (Pass/Fail) | Notes |
| --- | --- | --- | --- | --- | --- |
| 1 | Add expense amount | Generate notification of deduction and remaining balance | Generated | Pass |  |
| 2 | Deduct 90% of amount | Generate notification "Budget close to limit" | Notification shown | Pass |  |

Post-conditions: System sends a notification when the budget is close to its limit.

## Automated Widget Tests Added

The following automated checks are included in `test/widget_test.dart`:

| Test | Coverage |
| --- | --- |
| Add income requires an amount when Add is pressed | Rejects empty income amount. |
| Add income rejects zero amount | Rejects zero income amount. |
| Add income accepts valid amount format | Accepts a valid income amount format. |
| Add income rejects leading zero amount | Rejects values like `01`. |
| Add expense rejects zero amount | Rejects zero expense amount. |
| Add expense rejects leading zero amount | Rejects values like `01`. |
| Update expense validates budget amount | Rejects zero budget amount. |
| Search transactions: press Search without input | Shows "No transactions found." when Search is pressed. |
| Search transactions: do not perform search | Keeps results hidden before Search is pressed. |
| Search transactions: enter dates and press search | Opens both date fields and performs search. |
| Search transactions: sort by latest | Verifies the Newest sort control is available. |
| Search transactions: sort by oldest | Verifies the Oldest sort control is available. |
| Category suggestions in Home: open Home page | Verifies the search bar is visible. |
| Category suggestions in Home: type "f" | Shows Food and filters unrelated categories. |
| Category suggestions in Home: type partial text "tr" | Shows Transport from partial input. |
| Category suggestions in Home: type full category name | Shows only the selected full category. |
| Category suggestions in Home: enter invalid text | Shows Not found for invalid input. |
| Delete expenses / income: press delete icon | Shows the confirmation dialog. |
| Delete expenses / income: click "Cancel" | Closes the dialog and keeps the item. |
| Delete expenses / income: press delete icon again | Shows the confirmation dialog again. |
| Delete expenses / income: click "Yes" | Confirms deletion and removes the item. |
| Contextual reminders: add expenses amount | Calculates the remaining budget after adding an expense amount. |
| Contextual reminders: deduct 90% of amount | Confirms the close-to-limit reminder is triggered at 90% spending. |
| AI chatbot answers ready expense question | Confirms ready chatbot questions return the expected answer. |
