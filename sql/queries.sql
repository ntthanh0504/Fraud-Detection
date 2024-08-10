-- High Transaction Amounts During Unusual Hours:
-- What are the top 100 highest transactions during early morning hours (7-9 AM), and who are the involved merchants?
SELECT
	"TransactionID",
	"TransactionDate",
	"Amount",
	"CustomerName",
	"MerchantName"
FROM
	TRANSACTIONS_CREDITCARDS_CUSTOMERS_MERCHANTS
WHERE
	DATE_PART('hour', "TransactionDate") BETWEEN 7 AND 9
ORDER BY
	"Amount" DESC
LIMIT
	100;

-- Low Value Transactions:
-- Which customers have a high frequency of low-value transactions (less than $2.00)?
SELECT
	CC."CustomerID",
	C."CustomerName",
	COUNT(T."TransactionID") AS "LowValueTransactionCount"
FROM
	PUBLIC."Transactions" AS T
	INNER JOIN PUBLIC."CreditCards" AS CC ON T."CreditCardNumber" = CC."CreditCardNumber"
	INNER JOIN PUBLIC."Customers" AS C ON CC."CustomerID" = C."CustomerID"
WHERE
	T."Amount" < 2.00
GROUP BY
	CC."CustomerID",
	C."CustomerName"
HAVING
	COUNT(T."TransactionID") > 10
ORDER BY
	"LowValueTransactionCount" DESC;

-- Are there any patterns of repeated low-value transactions on specific days or times?
WITH
	TRANSACTION_TIME_DETAILS AS (
		SELECT
			"TransactionID",
			"TransactionDate",
			"Amount",
			"CreditCardNumber",
			"MerchantID",
			EXTRACT(
				DOW
				FROM
					"TransactionDate"
			) AS "DayOfWeek",
			EXTRACT(
				HOUR
				FROM
					"TransactionDate"
			) AS "HourOfDay"
		FROM
			"Transactions"
	)
SELECT
	"DayOfWeek",
	"HourOfDay",
	COUNT("TransactionID") AS "LowValueTransactionCount"
FROM
	TRANSACTION_TIME_DETAILS
WHERE
	"Amount" < 2.00
GROUP BY
	"DayOfWeek",
	"HourOfDay"
ORDER BY
	"DayOfWeek",
	"HourOfDay";

-- Which merchants have the highest count of transactions below $2.00, and is there any indication of these being potential test transactions by fraudsters?
SELECT
	M."MerchantID",
	M."MerchantName",
	COUNT(T."TransactionID") AS "LowValueTransactionCount"
FROM
	PUBLIC."Transactions" AS T
	INNER JOIN PUBLIC."Merchants" AS M ON T."MerchantID" = M."MerchantID"
WHERE
	T."Amount" < 2.00
GROUP BY
	M."MerchantID",
	M."MerchantName"
ORDER BY
	"LowValueTransactionCount" DESC
LIMIT
	5
	
-- Unusual Transaction Volumes:
-- Are there any customers with an unusually high number of transactions in a short period?
SELECT
	"CustomerID",
	"CustomerName",
	"Month",
	"Day",
	"HourOfDay",
	COUNT("TransactionID") AS "NumberOfTransactions",
	SUM("Amount") AS "TotalOfAmount"
FROM
	TRANSACTIONS_CREDITCARDS_CUSTOMERS_MERCHANTS
GROUP BY
	"CustomerID",
	"CustomerName",
	"Month",
	"Day",
	"HourOfDay"
ORDER BY
	"CustomerID"
	
-- Do specific merchants experience spikes in transaction volumes that don't align with typical business patterns?
WITH
	AVERAGE_DAILY_TRANSACTION_VOLUME AS (
		SELECT
			M."MerchantID",
			M."MerchantName",
			DATE (T."TransactionDate") AS TRANSACTION_DATE,
			COUNT(T."TransactionID") AS DAILY_TRANSACTION_COUNT
		FROM
			"Transactions" T
			JOIN "Merchants" M ON T."MerchantID" = M."MerchantID"
		GROUP BY
			M."MerchantID",
			M."MerchantName",
			DATE (T."TransactionDate")
	),
	MERCHANT_DAILY_AVERAGE_VOLUME AS (
		SELECT
			"MerchantID",
			"MerchantName",
			AVG(DAILY_TRANSACTION_COUNT) AS AVERAGE_DAILY_VOLUME
		FROM
			AVERAGE_DAILY_TRANSACTION_VOLUME
		GROUP BY
			"MerchantID",
			"MerchantName"
	)
SELECT
	A."MerchantID",
	A."MerchantName",
	A.TRANSACTION_DATE,
	A.DAILY_TRANSACTION_COUNT,
	MDA.AVERAGE_DAILY_VOLUME
FROM
	AVERAGE_DAILY_TRANSACTION_VOLUME A
	JOIN MERCHANT_DAILY_AVERAGE_VOLUME MDA ON A."MerchantID" = MDA."MerchantID"
WHERE
	A.DAILY_TRANSACTION_COUNT > 2 * MDA.AVERAGE_DAILY_VOLUME
ORDER BY
	A."MerchantID",
	A.TRANSACTION_DATE;

-- Customer Behavior Patterns:
-- Are there any customers who have changed their transaction patterns drastically (e.g., sudden increase in spending, change in transaction types)?
WITH
	AVERAGE_DAILY_TRANSACTION_VOLUME AS (
		SELECT
			C."CustomerID",
			C."CustomerName",
			DATE (T."TransactionDate") AS TRANSACTION_DATE,
			SUM(T."Amount") AS DAILY_AMOUNT_SUM
		FROM
			"Transactions" T
			JOIN "CreditCards" CC ON T."CreditCardNumber" = CC."CreditCardNumber"
			JOIN "Customers" C ON CC."CustomerID" = C."CustomerID"
		GROUP BY
			C."CustomerID",
			C."CustomerName",
			DATE (T."TransactionDate")
	),
	CUSTOMER_DAILY_AVERAGE_VOLUME AS (
		SELECT
			"CustomerID",
			"CustomerName",
			AVG(DAILY_AMOUNT_SUM) AS AVERAGE_DAILY_AMOUNT,
			STDDEV_SAMP(DAILY_AMOUNT_SUM) AS STD_DAILY_AMOUNT
		FROM
			AVERAGE_DAILY_TRANSACTION_VOLUME
		GROUP BY
			"CustomerID",
			"CustomerName"
	)
SELECT
	A."CustomerID",
	A."CustomerName",
	A.TRANSACTION_DATE,
	A.DAILY_AMOUNT_SUM,
	ABS(A.DAILY_AMOUNT_SUM - C.AVERAGE_DAILY_AMOUNT) / C.STD_DAILY_AMOUNT AS NUM_STDDEVS
FROM
	AVERAGE_DAILY_TRANSACTION_VOLUME A
	INNER JOIN CUSTOMER_DAILY_AVERAGE_VOLUME C ON A."CustomerID" = C."CustomerID"
WHERE
	ABS(A.DAILY_AMOUNT_SUM - C.AVERAGE_DAILY_AMOUNT) / C.STD_DAILY_AMOUNT > 3
ORDER BY
	A."CustomerID",
	A.TRANSACTION_DATE;

-- Do specific customers have transactions across a wide range of merchants, indicating potential card skimming or theft?
SELECT
	"CustomerName",
	COUNT(DISTINCT "MerchantID") AS "NumberOfMerchants"
FROM
	TRANSACTIONS_CREDITCARDS_CUSTOMERS_MERCHANTS
GROUP BY
	"CustomerName"
ORDER BY
	"NumberOfMerchants" DESC

-- Transaction Recurrence:
-- Are there repeated transactions of the same amount from the same credit card within a short period?
SELECT
	"CustomerName",
	"HourOfDay",
	"Amount",
	COUNT(DISTINCT "MerchantID") AS "NumberOfTransactions"
FROM
	TRANSACTIONS_CREDITCARDS_CUSTOMERS_MERCHANTS
GROUP BY
	"CustomerName",
	"HourOfDay",
	"Amount"
ORDER BY
	"NumberOfTransactions" DESC