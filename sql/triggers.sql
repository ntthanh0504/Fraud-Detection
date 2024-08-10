-- Ensure positive amount trigger
CREATE TRIGGER ensure_positive_amount_trigger
BEFORE INSERT OR UPDATE ON "Transactions"
FOR EACH ROW
EXECUTE FUNCTION ENSURE_POSITIVE_AMOUNT();

-- Log deleted transactions trigger
CREATE TRIGGER log_deleted_transactions_trigger
AFTER DELETE ON "Transactions"
FOR EACH ROW
EXECUTE FUNCTION LOG_DELETED_TRANSACTIONS();

-- Prevent customer deletion if active cards trigger
CREATE TRIGGER prevent_customer_deletion_if_active_cards_trigger
BEFORE DELETE ON "Customers"
FOR EACH ROW
EXECUTE FUNCTION PREVENT_CUSTOMER_DELETION_IF_ACTIVE_CARDS();

-- Update merchant transaction count trigger
CREATE TRIGGER update_merchant_transaction_count_trigger
AFTER INSERT ON "Transactions"
FOR EACH ROW
EXECUTE FUNCTION UPDATE_MERCHANT_TRANSACTION_COUNT();

-- Ensure transaction date not in future trigger
CREATE TRIGGER ensure_transaction_date_not_in_future_trigger
BEFORE INSERT OR UPDATE ON "Transactions"
FOR EACH ROW
EXECUTE FUNCTION ENSURE_TRANSACTION_DATE_NOT_IN_FUTURE();

-- Archive old transactions trigger
CREATE TRIGGER archive_old_transactions_trigger
BEFORE INSERT ON "Transactions"
FOR EACH ROW
EXECUTE FUNCTION ARCHIVE_OLD_TRANSACTIONS();
