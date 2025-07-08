-- Exercici 1
-- La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit.
-- La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules 
-- ("transaction" i "company"). Després de crear la taula serà necessari que ingressis la informació del document denominat
-- "dades_introduir_credit". Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.

 USE transactions;

    -- Creamos la tabla credit_card
    CREATE TABLE IF NOT EXISTS credit_card (
        id VARCHAR(15) PRIMARY KEY,
        iban VARCHAR(50),
        pan VARCHAR(35),
        pin VARCHAR(4),
        cvv INT,
        expiring_date VARCHAR(15)
    );
    
-- Cargamos los datos de la nueva tabla credit_card.
    
-- Realizamos la conexion entre las tablas transaction y la nueva tabla de dimensiones credit_card     

ALTER TABLE transaction 
ADD CONSTRAINT fk_transaction_credit_card
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);

-- Exercici 2
-- El departament de Recursos Humans ha identificat un error en el número de compte associat a la targeta de crèdit amb ID CcU-2938.
-- La informació que ha de mostrar-se per a aquest registre és: TR323456312213576817699999. 
-- Recorda mostrar que el canvi es va realitzar.
SELECT iban 
FROM credit_card
WHERE id = 'CcU-2938';

-- Para modificarlo realizaremos el siguiente código

UPDATE credit_card SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';

-- EXERCICI 3
-- En la taula "transaction" ingressa un nou usuari amb la següent informació:
-- Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
-- credit_card_id	CcU-9999
-- company_id	b-9999
-- user_id	9999
-- lat	829.999
-- longitude	-117.999
-- amount	111.11
-- declined	0

-- Primero introducimos un nuevo valor en la tabla company
INSERT INTO company (id)
VALUES ('b-9999');

-- Seguidamente realizamos lo mismo en la tabla credit_card

INSERT INTO credit_card (id)
VALUES ('CcU-9999');


-- Insertamos la siguiente información en la tabla transaction

INSERT INTO transaction (Id, credit_card_id, company_id, user_id, lat, longitude, amount, declined) 
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999','9999', '829.999', '-117.999', '111.11', 0);




-- realizamos la comprobación de que el nuevo registro de ha cargado en la tabla transaction.
SELECT * 
FROM transaction
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';



-- Exercici 4
-- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. 
-- Recorda mostrar el canvi realitzat.

ALTER TABLE credit_card
DROP COLUMN pan;

SELECT * 
FROM credit_card;

-- Nivell 2
-- Exercici 1
-- Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.

DELETE FROM transaction
WHERE id ='000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

SELECT * FROM transaction
WHERE id ='000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- Exercici 2
-- La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives.
-- S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions.
-- Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació:
-- Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia.
-- Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.vista

-- Creación de la vista vistamarketing
CREATE VIEW vistamarketing AS
SELECT c.company_name, c.phone, c.country, ROUND(AVG(t.amount),2) AS mitjana_compra
FROM company c
INNER JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY c.company_name, c.phone, c.country 
ORDER BY mitjana_compra DESC;

SELECT *
FROM vistamarketing;

-- Exercici 3
-- Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"

SELECT * FROM vistamarketing
WHERE country = 'Germany';

--  Nivell 3
-- Exercici 1
-- La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip va realitzar modificacions
-- en la base de dades, però no recorda com les va realitzar. Et demana que l'ajudis a deixar els comandos executats 
-- per a obtenir el següent diagrama:

-- creamos la tabla data_user:
CREATE TABLE IF NOT EXISTS user (
	id CHAR(10) PRIMARY KEY,
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

-- Cambio el nombre de la tabla de user a data_user con el rename.
ALTER TABLE user RENAME TO data_user;

-- Realizamos el cambio de la columna email por personal_email en la tabla data_user

ALTER TABLE data_user
CHANGE COLUMN email personal_email VARCHAR (150) NULL;
-- Crear en la tabla data_user el nuevo usuario del ejercicio 3 del primer nivel

INSERT INTO data_user (id)
Values ('9999');
--

-- Una vez cargados todos lo datos de la tabla realizamos un cambio del tipo de datos para poder generar la relación 
-- ya que si no coincide el tipo de dato no podra realizar la conexión en el EER.

ALTER TABLE data_user MODIFY COLUMN id INT;

-- Crear relación entre la tabla transaction y data_user
ALTER TABLE transaction 
ADD CONSTRAINT fk_transaction_data_user
FOREIGN KEY (user_id)
REFERENCES data_user(id);




-- Eliminamos la columna website de la tabla company

ALTER TABLE company
DROP COLUMN website;

-- Romper la relación entre transaction y credit_card 

ALTER TABLE transaction DROP FOREIGN KEY FK_transaction_credit_card;

-- Cambiamos la longitud de la variable id en la tabla credit_card

ALTER TABLE credit_card MODIFY COLUMN id varchar (20);
DESCRIBE credit_card;

-- Cambiamos la longitud de la variable credit_card_id de la tabla transaction.

ALTER TABLE transaction MODIFY COLUMN credit_card_id varchar (20);
DESCRIBE transaction;

-- Creamos la nueva columna fecha_actual en la tabla credit_card

ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE NULL;

-- cambiar la longitud de la variable expiring_date de la tabla credit_card

ALTER TABLE credit_card MODIFY COLUMN expiring_date varchar (20);
DESCRIBE credit_card;

-- Despues de realizar todos los cambios volveremos a conectar la tabla transaction con la tabla credit_card

ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_credit_card
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);


-- Exercici 2
-- L'empresa també us demana crear una vista anomenada "InformeTecnico" que contingui la següent informació:

-- ID de la transacció
-- Nom de l'usuari/ària
-- Cognom de l'usuari/ària
-- IBAN de la targeta de crèdit usada.
-- Nom de la companyia de la transacció realitzada.
-- Assegureu-vos d'incloure informació rellevant de les taules que coneixereu i utilitzeu àlies per canviar de nom columnes segons calgui.
-- Mostra els resultats de la vista, ordena els resultats de forma descendent en funció de la variable ID de transacció.

CREATE VIEW InformeTecnico AS
SELECT 
    t.id AS id_transaccio,
    u.name AS nom_usuari,
    u.surname AS cognom_usuari,
    cc.iban AS iban_targeta,
    c.company_name AS nom_companyia
FROM transaction t
JOIN data_user u ON t.user_id = u.id
JOIN credit_card cc ON t.credit_card_id = cc.id
JOIN company c ON t.company_id = c.id
ORDER BY id_transaccio DESC;

SELECT * FROM informetecnico;