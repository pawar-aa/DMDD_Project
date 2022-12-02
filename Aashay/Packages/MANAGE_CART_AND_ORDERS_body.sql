create or replace PACKAGE BODY MANAGE_CART_AND_ORDERS AS

-------------------------------------------------------------------------------
--CREATE CART IN CART_TABLE
-------------------------------------------------------------------------------
PROCEDURE CREATE_CART(USER_ID INT) IS
M_USER_ID INT;
NEXT_COUNT INT;
V_COUNT INT;
BEGIN
    M_USER_ID:=USER_ID;
    SELECT COUNT(*) INTO V_COUNT  FROM CART WHERE CART.USER_ID = M_USER_ID;
    DBMS_OUTPUT.PUT_LINE('V_COUNT: '|| V_COUNT);
    IF(V_COUNT = 0) THEN
        SELECT COUNT(*)+1 INTO NEXT_COUNT FROM CART;
        EXECUTE IMMEDIATE('INSERT INTO CART VALUES('||NEXT_COUNT||', '||USER_ID||', 0)');
        DBMS_OUTPUT.PUT_LINE('CREATED CART FOR USER');
    ELSE
        DBMS_OUTPUT.PUT_LINE('CART EXISTS FOR USER');
    END IF;
END;


-------------------------------------------------------------------------------
--ADD A PRODUCT TO CART_ITEM TABLE
-------------------------------------------------------------------------------
PROCEDURE ADD_CART_ITEM(USER_ID INT,PRODUCT_NAME VARCHAR,QTY INT) IS
M_USER_ID INT;
M_PRODUCT_NAME VARCHAR(255);
M_QTY INT;
M_AVAILABLE_QTY INT;
M_CART_ITEM_ID INT;
M_CART_ID INT;
BEGIN
    M_USER_ID:=USER_ID;
    M_PRODUCT_NAME:=PRODUCT_NAME;
    M_QTY:=QTY;
    -- !!AS USER_ID IS SAME AS CART_ID!! (DISCUSSED)
    M_CART_ID:=USER_ID;
    SELECT QUANTITY INTO M_AVAILABLE_QTY FROM PRODUCT WHERE PRODUCT_NAME=M_PRODUCT_NAME;
    IF(M_QTY > M_AVAILABLE_QTY) THEN
        DBMS_OUTPUT.PUT_LINE('SELECTED QTY MORE THAN AVAILABLE QTY, AVAILABLE QTY: ' || M_AVAILABLE_QTY);
    ELSE
        SELECT COUNT(*)+1 INTO M_CART_ITEM_ID FROM CART_ITEM;
        SELECT PRODUCT_ID INTO M_PRODUCT_NAME FROM PRODUCT WHERE PRODUCT_NAME = M_PRODUCT_NAME;
        INSERT INTO CART_ITEM VALUES(M_CART_ITEM_ID, M_CART_ID, M_PRODUCT_NAME, M_QTY);
    END IF;
END;


-------------------------------------------------------------------------------
--CREATE A ORDER AND ADD A ROW IN ORDERS TABLE
-------------------------------------------------------------------------------
PROCEDURE CREATE_ORDER(USER_ID INT, ADDRESS_ID INT) IS
M_ORDER_ID INT;
M_USER_ID INT;
M_ADDRESS_ID INT;
M_ORDER_STATUS VARCHAR(255);
M_ORDER_DATE DATE;
BEGIN
    M_USER_ID:=USER_ID;
    M_ADDRESS_ID:=ADDRESS_ID;
    M_ORDER_STATUS:='ORDERED';
    SELECT COUNT(*)+1 INTO M_ORDER_ID FROM ORDERS;
    SELECT CURRENT_DATE INTO M_ORDER_DATE FROM DUAL;
    INSERT INTO ORDERS VALUES(M_ORDER_ID, M_ORDER_STATUS, M_USER_ID, M_ORDER_DATE, M_ADDRESS_ID);
    DBMS_OUTPUT.PUT_LINE('NEW ORDER CREATED');
END;


-------------------------------------------------------------------------------
--TRANSFER CART_ITEMS DETAILS INTO ORDER_ITEMS, UPDATES PRODUCT QUANTITY
-------------------------------------------------------------------------------
PROCEDURE ADD_ORDER_ITEMS(USER_ID INT) IS
M_USER_ID INT;
M_ORDER_ID INT;
M_ORDER_ITEM_ID INT;
M_PRODUCT_ID INT;
M_PRODUCT_QTY INT;
M_PRODUCT_AVAILABLE_QTY INT;
M_LOOP_COUNT INT;
BEGIN
    M_USER_ID:=USER_ID;
    SELECT COUNT(*) INTO M_LOOP_COUNT FROM CART_ITEM WHERE CART_ID = M_USER_ID;
    SELECT COUNT(*) INTO M_ORDER_ID FROM ORDERS;
    
    FOR I IN 0..M_LOOP_COUNT-1 
        LOOP
            SELECT COUNT(*)+1 INTO M_ORDER_ITEM_ID FROM ORDER_ITEM;
            select product_id into m_product_id from (SELECT PRODUCT_ID FROM cart_item WHERE cart_id=m_user_id) where rownum=1;
            select quantity into m_product_qty from (SELECT quantity FROM cart_item WHERE cart_id=m_user_id) where rownum=1;
            
            dbms_output.put_line(M_ORDER_ITEM_ID || M_ORDER_ID || M_PRODUCT_ID || M_PRODUCT_QTY);
        
            INSERT INTO ORDER_ITEM VALUES(M_ORDER_ITEM_ID, M_ORDER_ID, M_PRODUCT_ID, M_PRODUCT_QTY);
        
            DELETE FROM CART_ITEM WHERE CART_ID = M_USER_ID AND PRODUCT_ID = M_PRODUCT_ID;
            
            SELECT QUANTITY INTO M_PRODUCT_AVAILABLE_QTY FROM PRODUCT WHERE PRODUCT_ID = M_PRODUCT_ID;
            UPDATE PRODUCT SET QUANTITY=M_PRODUCT_AVAILABLE_QTY-M_PRODUCT_QTY WHERE PRODUCT_ID = M_PRODUCT_ID;
            
        END LOOP; 
END;


-------------------------------------------------------------------------------
--TRUNCATE USER DATA FROM CART_ITEM TABLE
-------------------------------------------------------------------------------
PROCEDURE DELETE_CART_ITEM(USER_ID INT) IS
M_USER_ID INT;
BEGIN
    M_USER_ID:=USER_ID;
    -- !!AS USER_ID IS SAME AS CART_ID!! (DISCUSSED)
    DELETE FROM CART_ITEM WHERE CART_ID = M_USER_ID;
END;


-------------------------------------------------------------------------------
END;