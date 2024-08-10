-- Exported from QuickDBD: https://www.quickdatabasediagrams.com/
-- Link to schema: https://app.quickdatabasediagrams.com/#/d/9k0juL
-- NOTE! If you have used non-SQL datatypes in your design, you will have to change these here.
CREATE TABLE "Customers" (
	"CustomerID" INT NOT NULL,
	"CustomerName" VARCHAR(100) NOT NULL,
	CONSTRAINT "pk_Customers" PRIMARY KEY ("CustomerID")
);

CREATE TABLE "CreditCards" (
	"CreditCardNumber" VARCHAR(20) NOT NULL,
	"CustomerID" INT NOT NULL,
	CONSTRAINT "pk_CreditCards" PRIMARY KEY ("CreditCardNumber")
);

CREATE TABLE "MerchantCategories" (
	"MerchantCategoryID" SERIAL NOT NULL,
	"CategoryName" VARCHAR(20) NOT NULL CHECK (CHAR_LENGTH("CategoryName") > 0),
	CONSTRAINT "pk_MerchantCategories" PRIMARY KEY ("MerchantCategoryID")
);

CREATE TABLE "Merchants" (
	"MerchantID" SERIAL NOT NULL,
	"MerchantName" VARCHAR(20) NOT NULL CHECK (CHAR_LENGTH("MerchantName") > 0),
	"MerchantCategoryID" INT NULL,
	CONSTRAINT "pk_Merchants" PRIMARY KEY ("MerchantID")
);

CREATE TABLE "Transactions" (
	"TransactionID" INT NOT NULL,
	"TransactionDate" TIMESTAMP NOT NULL,
	"Amount" FLOAT NULL CHECK ("Amount" > 0),
	"CreditCardNumber" VARCHAR(20) NULL,
	"MerchantID" INT NULL,
	CONSTRAINT "pk_Transactions" PRIMARY KEY ("TransactionID")
);

ALTER TABLE "CreditCards"
ADD CONSTRAINT "fk_CreditCards_CustomerID" FOREIGN KEY ("CustomerID") REFERENCES "Customers" ("CustomerID");

ALTER TABLE "Merchants"
ADD CONSTRAINT "fk_Merchants_MerchantCategoryID" FOREIGN KEY ("MerchantCategoryID") REFERENCES "MerchantCategories" ("MerchantCategoryID");

ALTER TABLE "Transactions"
ADD CONSTRAINT "fk_Transactions_CreditCardNumber" FOREIGN KEY ("CreditCardNumber") REFERENCES "CreditCards" ("CreditCardNumber");

ALTER TABLE "Transactions"
ADD CONSTRAINT "fk_Transactions_MerchantID" FOREIGN KEY ("MerchantID") REFERENCES "Merchants" ("MerchantID");

CREATE INDEX "idx_Customers_CustomerName" ON "Customers" ("CustomerName");