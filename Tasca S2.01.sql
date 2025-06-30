-- NIVEL 1
-- Exercici 2
-- Utilitzant JOIN realitzaràs les següents consultes:

-- a-Llistat dels països que estan generant vendes.
SELECT  DISTINCT c.country
FROM company c
JOIN transaction t  ON c.id = t.company_id
WHERE t.declined = 0;

-- b -Des de quants països es generen les vendes.

SELECT COUNT(DISTINCT c.country) AS num_paisos
FROM company c 
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0;

-- c -Identifica la companyia amb la mitjana més gran de vendes.

SELECT c.company_name, AVG(t.amount) AS mitjana_vendes
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0 
GROUP BY c.company_name
ORDER BY mitjana_vendes DESC
LIMIT 1;

-- Exercici 3
-- Utilitzant només subconsultes (sense utilitzar JOIN):
    -- a- Mostra totes les transaccions realitzades per empreses d'Alemanya.
    
    SELECT * 
    FROM transaction
    WHERE declined = 0 AND company_id IN (
			SELECT id 
			FROM company
			WHERE country = 'Germany'); 
            
    
-- b-Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.

                
SELECT id, company_name, country
FROM company
WHERE id IN (SELECT DISTINCT company_id
		FROM transaction
		WHERE amount > (SELECT AVG(amount)
				FROM transaction
				WHERE declined = 0));
-- c-   Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses. 

SELECT *
FROM company
WHERE id NOT IN (
	 SELECT DISTINCT company_id 
    FROM transaction
    WHERE declined = 0);
    
-- NIVEL 2
-- Ejercicio 1 Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
-- Mostra la data de cada transacció juntament amb el total de les vendes. 
   
SELECT DATE(timestamp) AS data_transaccion, SUM(amount) AS total_ventas
FROM transaction
WHERE declined = 0
GROUP BY data_transaccion
ORDER BY total_ventas DESC
LIMIT 5;
   
-- Ejercicio 2 Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.

SELECT c.country,ROUND(AVG(t.amount),2) AS media_ventas
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY c.country
ORDER BY media_ventas DESC;    

-- Ejercicio 3 En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries
--  per a fer competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les
-- transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.

-- Mostra el llistat aplicant JOIN i subconsultes. 
SELECT t.*
FROM transaction t 
JOIN company c ON t.company_id = c.id
WHERE t.declined = 0 AND c .country IN ( 
	SELECT country
	FROM company
	WHERE company_name = 'Non Institute')
    AND company_name!= 'Non Institute';	
    


-- Mostra el llistat aplicant solament subconsultes.
SELECT *
FROM transaction
WHERE declined = 0 AND company_id IN 
	(SELECT id
	FROM company
	WHERE country IN (
			SELECT country
            FROM company
            WHERE company_name = 'Non Institute') 
            AND company_name!= 'Non Institute'
);    

-- NIVEL 3    
-- Ejercicio 1
-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès
-- entre 350 i 400 euros i en alguna d'aquestes dates: 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024.
-- Ordena els resultats de major a menor quantitat.

SELECT c.company_name, c.phone, c.country, t.timestamp, t.amount
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.amount BETWEEN 350 AND 400 AND DATE(t.timestamp) IN ('2015-04-29','2018-7-20','2024-3-13') AND t.declined = 0
ORDER BY t.amount DESC;

-- Ejercicio 2
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
-- per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses,
-- però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis 
-- si tenen més de 400 transaccions o menys.

SELECT c.company_name, COUNT(t.id) AS num_transactions,
CASE
	WHEN COUNT(t.id) > 400 THEN 'Mas de 400'
    ELSE '400 o Menos'
END AS clasificación
FROM company c 
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY c.company_name
ORDER BY num_transactions DESC;

    
        
    
