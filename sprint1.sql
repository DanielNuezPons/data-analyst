USE transactions;
SELECT * FROM company;
SELECT * FROM transaction;

-- Exercici 1 
-- A partir dels documents adjunts (estructura_dades i dades_introduir), importa les dues taules.
-- Mostra les característiques principals de l'esquema creat i explica les diferents taules i variables que existeixen.
-- Assegura't d'incloure un diagrama que il·lustri la relació entre les diferents taules i variables.

-- En este ejercicio tenemos la base de datos transactions que a su vez esta formada por 2 tablas, la primera tabla company
-- esta formada por 6 columnas las cuales nos aportan cierta información importante de esa tabla. Tenemos una primary key que 
-- en este caso es la columna id que todos sus valores seran unicos y el resto de columnas esta compuesto de foreing Key



-- Exercici 2
-- Utilitzant JOIN realitzaràs les següents consultes:

-- a) Llistat dels països que estan fent compres.

SELECT DISTINCT c.country
FROM transaction t
JOIN company c ON t.company_id = c.id
WHERE t.declined = 0;
-- b) Des de quants països es realitzen les compres.

SELECT COUNT(DISTINCT c.country) AS num_paisos
FROM transaction t
JOIN company c ON t.company_id = c.id
WHERE t.declined = 0;


-- c) Identifica la companyia amb la mitjana més gran de vendes.

SELECT c.company_name, AVG(t.amount) AS mitjana_vendes
FROM transaction t
JOIN company c ON t.company_id = c.id
WHERE t.declined = 0
GROUP BY c.company_name
ORDER BY mitjana_vendes DESC
LIMIT 1;

-- Exercici 3 
-- Utilitzant només subconsultes (sense utilitzar JOIN):

-- Mostra totes les transaccions realitzades per empreses d'Alemanya.
-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.