-- ROLLBACK;
CREATE
OR REPLACE FUNCTION ENSURE_POSITIVE_AMOUNT () RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Amount <= 0 THEN
        RAISE EXCEPTION 'Transaction amount must be greater than 0';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION LOG_DELETED_TRANSACTIONS () RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO "TransactionLogs" ("TransactionID", "TransactionDate", "Amount", "CreditCardNumber", "MerchantID")
    VALUES (OLD."TransactionID", OLD."TransactionDate", OLD."Amount", OLD."CreditCardNumber", OLD."MerchantID");
    RETURN OLD;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION PREVENT_CUSTOMER_DELETION_IF_ACTIVE_CARDS () RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM "CreditCards" WHERE "CustomerID" = OLD."CustomerID") THEN
        RAISE EXCEPTION 'Cannot delete customer with active credit cards';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION UPDATE_MERCHANT_TRANSACTION_COUNT () RETURNS TRIGGER AS $$
BEGIN
    UPDATE "Merchants"
    SET "TransactionCount" = "TransactionCount" + 1
    WHERE "MerchantID" = NEW."MerchantID";
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION ENSURE_TRANSACTION_DATE_NOT_IN_FUTURE () RETURNS TRIGGER AS $$
BEGIN
    IF NEW."TransactionDate" > CURRENT_TIMESTAMP THEN
        RAISE EXCEPTION 'Transaction date cannot be in the future.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE FUNCTION ARCHIVE_OLD_TRANSACTIONS () RETURNS TRIGGER AS $$
BEGIN
    IF NEW."TransactionDate" < CURRENT_DATE - INTERVAL '1 year' THEN
        INSERT INTO "ArchivedTransactions" ("TransactionID", "TransactionDate", "Amount", "CreditCardNumber", "MerchantID")
        VALUES (NEW."TransactionID", NEW."TransactionDate", NEW."Amount", NEW."CreditCardNumber", NEW."MerchantID");
        DELETE FROM "Transactions" WHERE "TransactionID" = NEW."TransactionID";
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;