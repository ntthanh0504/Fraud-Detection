CREATE OR REPLACE VIEW TRANSACTIONS_CREDITCARDS_CUSTOMERS_MERCHANTS AS
SELECT
	T."TransactionID",
	T."TransactionDate",
	T."Amount",
	CC."CreditCardNumber",
	C."CustomerID",
	C."CustomerName",
	M."MerchantID",
	M."MerchantName",
	EXTRACT(
		MONTH
		FROM
			T."TransactionDate"
	) AS "Month",
	EXTRACT(
		DAY
		FROM
			T."TransactionDate"
	) AS "Day",
	EXTRACT(
		HOUR
		FROM
			T."TransactionDate"
	) AS "HourOfDay"
FROM
	"Transactions" AS T
	INNER JOIN "CreditCards" AS CC ON T."CreditCardNumber" = CC."CreditCardNumber"
	INNER JOIN "Customers" AS C ON CC."CustomerID" = C."CustomerID"
	INNER JOIN "Merchants" AS M ON T."MerchantID" = M."MerchantID";

-- ===================================
CREATE OR REPLACE VIEW TRANSACTIONS_CREDITCARDS_CUSTOMERS_MERCHANTS_CATEGORIES AS
SELECT
	T."TransactionID",
	T."TransactionDate",
	T."Amount",
	CC."CreditCardNumber",
	C."CustomerID",
	C."CustomerName",
	M."MerchantID",
	M."MerchantName",
	MC."CategoryName" AS "Category"
FROM
	"Transactions" AS T
	INNER JOIN "CreditCards" AS CC ON T."CreditCardNumber" = CC."CreditCardNumber"
	INNER JOIN "Customers" AS C ON CC."CustomerID" = C."CustomerID"
	INNER JOIN "Merchants" AS M ON T."MerchantID" = M."MerchantID"
	INNER JOIN "MerchantCategories" AS MC ON M."MerchantCategoryID" = MC."MerchantCategoryID";