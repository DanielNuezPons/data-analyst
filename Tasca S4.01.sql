CREATE SCHEMA data;

USE data;

-- Creamos la tabla companies 
    CREATE TABLE IF NOT EXISTS companies (
        company_id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );
 SHOW VARIABLES LIKE "secure_file_priv"; -- para ver desde la ruta que tenemos que cargar el archivo
 
 -- Carganos los datpos de la tabla companies
     
  LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv'
  INTO TABLE companies 
  FIELDS TERMINATED BY ','
  ENCLOSED BY ""
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES;
  
 -- Creamos la tabla credit_cards
	  CREATE TABLE IF NOT EXISTS credit_card (
        id VARCHAR(15) PRIMARY KEY,
        user_id INT,
        iban VARCHAR(50),
        pan VARCHAR(35),
        pin VARCHAR(4),
        cvv INT, 
        track1 VARCHAR(255),
        track2 VARCHAR(255),
        expiring_date DATE
    ); 
  
  -- Cargamos los datos de la tabla credit_card
    LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv'
  INTO TABLE credit_card
  FIELDS TERMINATED BY ','
  ENCLOSED BY ""
  LINES TERMINATED BY '\n'
  IGNORE 1 ROWS
  (id, user_id, iban, pan, pin, cvv, track1, track2, @expiring_date)
  SET expiring_date = STR_TO_DATE(@expiring_date, '%m/%d/%y');
  
 
-- Creamos la tabla users
	CREATE TABLE IF NOT EXISTS users (
	id INT PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255)    
);

-- Cargamos los datos de las tablas european_users y american_users
  
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\european_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address)
SET birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y');

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\american_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address)
SET birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y');

-- REalizamos el cambio de dato de la columna birth_date de varchar como lo habiamos creado a DATE.

ALTER TABLE users
MODIFY COLUMN birth_date DATE;
DESCRIBE users;

-- Creamos la tabla transactions que es nuestra tabla de hechos
CREATE TABLE IF NOT EXISTS transactions (
  id VARCHAR(100) PRIMARY KEY,
  card_id VARCHAR(15),
  bussiness_id VARCHAR(15),
  timestamp TIMESTAMP,
  amount DECIMAL(10, 2),
  declined BOOLEAN,
  product_ids CHAR(25),
  user_id INT,
  lat FLOAT,
  longitude FLOAT 
  );
  
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';' 
OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS;
  -- Realizamos la conexiones entre la tabla de hechos transaction y las tablas de dimensiones restantes
  
ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_users
FOREIGN KEY (user_id)
REFERENCES users(id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_credit_card
FOREIGN KEY (card_id)
REFERENCES credit_card(id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_companies
FOREIGN KEY (bussiness_id)
REFERENCES companies(company_id);

-- Exercici 1
-- Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.

SELECT CONCAT(u.name,' ',u.surname) AS nombre_completo, total_transactions
FROM users u 
JOIN 
	(
	SELECT t.user_id,COUNT(t.id) AS total_transactions
    FROM transactions t 
    WHERE declined = 0
    GROUP BY t.user_id
    HAVING total_transactions > 80
    ) AS ts  -- transaction superior a 80
ON u.id = ts.user_id;


    
    

-- Exercici 2
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.

SELECT cc.iban, c.company_name, ROUND(AVG(t.amount), 2) AS media_amount
FROM transactions t 
INNER JOIN credit_card cc ON t.card_id = cc.id
INNER JOIN companies c ON t.bussiness_id = c.company_id
WHERE c.company_name = 'Donec Ltd' AND t.declined = 0
GROUP BY cc.iban
ORDER BY media_amount DESC;

-- Nivell 2
-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes 
-- tres transaccions van ser declinades i genera la següent consulta:

CREATE TABLE IF NOT EXISTS estat_targetes AS
SELECT card_id,
		CASE 
			WHEN SUM(declined) = 3 THEN 'inactiva'
			ELSE 'activa'
        END AS estado_targeta
FROM 
	(SELECT card_id, declined,
    ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY timestamp DESC) AS contador
    FROM transactions
    ) AS transactions_organizadas
WHERE contador <= 3 
GROUP BY card_id;

DESCRIBE estat_targetes;

SELECT card_id 
FROM estat_targetes
WHERE estado_targeta = 'activa';

-- Unimos la tabla estat_targetes con la tabla credit_card
ALTER TABLE estat_targetes
ADD CONSTRAINT fk_estat_targetes_credit_card
FOREIGN KEY (card_id)
REFERENCES credit_card(id);


-- Nivell 3
-- Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada,
-- tenint en compte que des de transaction tens product_ids. Genera la següent consulta:

-- Creamos la tabla products
CREATE TABLE IF NOT EXISTS products (
	id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100),
    price VARCHAR(20),
    colour VARCHAR(30),
    weight DECIMAL(10,2),
    warehouse_id VARCHAR(20)
    );
    
    DESCRIBE products;
    
  -- cargamos lo datos del csv de products
  
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS;
-- comprobamos que los datos se hayan cargado correctamente.
SELECT*
FROM products;


-- Realizamos los siguientes cambios en la tabla products eliminar el simbolo $ de la columna 
-- La instrucción SET SQL_SAFE_UPDATES = 0 en MySQL deshabilita la protección que evita actualizaciones o eliminaciones sin una cláusula WHERE 
SET SQL_SAFE_UPDATES = 0;

UPDATE products
SET price = REPLACE(price, '$', '');

-- Volvemos a habiliar la protección

SET SQL_SAFE_UPDATES = 1;

-- Cambiamos el tipo de dato de varchar a decimal
ALTER TABLE products
MODIFY column price DECIMAL(10,2);


DESCRIBE products;

-- Creamos la tabla intermedia transactions_product

CREATE TABLE transactions_product(
transaction_id VARCHAR (100),
product_id VARCHAR (50),
PRIMARY KEY (transaction_id,product_id)
); 

-- Insertamos los datos en la tabla transactions_product

INSERT INTO transactions_product (transaction_id, product_id)
SELECT t.id AS transaction_id, p.id AS product_id
        FROM transactions t
        JOIN products p
        ON   FIND_IN_SET( p.id , REPLACE(t.product_ids, ' ', '')) > 0;

-- Uniremos las tablas transactions con transactions_product y transactions_product con products.

ALTER TABLE transactions_product
ADD CONSTRAINT fk_transactions_product_transactions
FOREIGN KEY (transaction_id)
REFERENCES transactions(id);

-- para poder unir la tabla transactions_product con products necesito cambiar el tipo de dato de la columna product_id

ALTER TABLE transactions_product
MODIFY COLUMN product_id INT;

-- Unimos la tabla transactions_product con la tabla products
ALTER TABLE transactions_product
ADD CONSTRAINT fk_transactions_product_products
FOREIGN KEY (product_id)
REFERENCES products(id);



-- Exercici 1
-- Necessitem conèixer el nombre de vegades que s'ha venut cada producte.

SELECT tp.product_id,p.product_name, COUNT(DISTINCT(tp.transaction_id)) AS cantidad_vendida
FROM transactions_product tp 
JOIN products p ON tp.product_id = p.id
JOIN transactions t ON tp.transaction_id = t.id
WHERE t.declined = 0 
GROUP BY product_id;




