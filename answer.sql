-- Week 7 Assignment: Database Design and Normalization
-- Run this script in MySQL 8.0+ (or a compatible MySQL environment).
-- The DROP TABLE statements make the script safe to run again from a clean state.

-- ============================================================
-- Question 1: Achieving First Normal Form (1NF)
-- ============================================================
-- The original Products column contains repeating values
-- (for example, "Laptop, Mouse"). In 1NF, each cell contains
-- one atomic value, so each order/product pair gets its own row.

DROP TABLE IF EXISTS ProductDetail_1NF;

CREATE TABLE ProductDetail_1NF (
    OrderID INT NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    Product VARCHAR(100) NOT NULL,
    PRIMARY KEY (OrderID, Product)
) ENGINE = InnoDB;

INSERT INTO ProductDetail_1NF (OrderID, CustomerName, Product)
VALUES
    (101, 'John Doe', 'Laptop'),
    (101, 'John Doe', 'Mouse'),
    (102, 'Jane Smith', 'Tablet'),
    (102, 'Jane Smith', 'Keyboard'),
    (102, 'Jane Smith', 'Mouse'),
    (103, 'Emily Clark', 'Phone');

-- Check the 1NF result: one product in each row.
SELECT OrderID, CustomerName, Product
FROM ProductDetail_1NF
ORDER BY OrderID, Product;


-- ============================================================
-- Question 2: Achieving Second Normal Form (2NF)
-- ============================================================
-- In the original OrderDetails table, the assumed composite
-- primary key is (OrderID, Product).
-- Partial dependency: CustomerName depends on OrderID alone,
-- not on the complete composite key. Move customer/order data
-- to Orders and keep product/quantity data in OrderItems.

DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Orders;

CREATE TABLE Orders (
    OrderID INT NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    PRIMARY KEY (OrderID)
) ENGINE = InnoDB;

CREATE TABLE OrderItems (
    OrderID INT NOT NULL,
    Product VARCHAR(100) NOT NULL,
    Quantity INT NOT NULL,
    PRIMARY KEY (OrderID, Product),
    CONSTRAINT fk_orderitems_orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders (OrderID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT chk_orderitems_quantity
        CHECK (Quantity > 0)
) ENGINE = InnoDB;

-- Insert each order/customer once.
INSERT INTO Orders (OrderID, CustomerName)
VALUES
    (101, 'John Doe'),
    (102, 'Jane Smith'),
    (103, 'Emily Clark');

-- Insert each product and its quantity for the corresponding order.
INSERT INTO OrderItems (OrderID, Product, Quantity)
VALUES
    (101, 'Laptop', 2),
    (101, 'Mouse', 1),
    (102, 'Tablet', 3),
    (102, 'Keyboard', 1),
    (102, 'Mouse', 2),
    (103, 'Phone', 1);

-- Check the normalized 2NF result by joining orders to their items.
SELECT
    o.OrderID,
    o.CustomerName,
    oi.Product,
    oi.Quantity
FROM Orders AS o
INNER JOIN OrderItems AS oi
    ON oi.OrderID = o.OrderID
ORDER BY o.OrderID, oi.Product;
