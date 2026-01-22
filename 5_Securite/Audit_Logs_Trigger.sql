-- ========================================
-- TRIGGERS SANS user_id (car c'est UUID vs INTEGER)
-- ========================================

-- 1. TRIGGER ACCOUNTS UPDATE
CREATE OR REPLACE FUNCTION log_account_update()
RETURNS TRIGGER AS $$
DECLARE
    v_user_email VARCHAR(255);
    v_user_role VARCHAR(50);
BEGIN
    SELECT email, role INTO v_user_email, v_user_role FROM get_user_info();
    
    INSERT INTO audit_logs (user_email, user_role, action, table_name, record_id, timestamp, ip_address)
    VALUES (v_user_email, v_user_role, 'UPDATE_ACCOUNT', 'accounts', NEW.account_id, NOW(), inet_client_addr()::VARCHAR(45));
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_log_account_update ON accounts;
CREATE TRIGGER trigger_log_account_update 
    AFTER UPDATE ON accounts 
    FOR EACH ROW 
    EXECUTE FUNCTION log_account_update();


-- 2. TRIGGER ACCOUNTS DELETE
CREATE OR REPLACE FUNCTION log_account_delete()
RETURNS TRIGGER AS $$
DECLARE
    v_user_email VARCHAR(255);
    v_user_role VARCHAR(50);
BEGIN
    SELECT email, role INTO v_user_email, v_user_role FROM get_user_info();
    
    INSERT INTO audit_logs (user_email, user_role, action, table_name, record_id, timestamp, ip_address)
    VALUES (v_user_email, v_user_role, 'DELETE_ACCOUNT', 'accounts', OLD.account_id, NOW(), inet_client_addr()::VARCHAR(45));
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_log_account_delete ON accounts;
CREATE TRIGGER trigger_log_account_delete 
    BEFORE DELETE ON accounts 
    FOR EACH ROW 
    EXECUTE FUNCTION log_account_delete();


-- 3. TRIGGER CUSTOMERS UPDATE
CREATE OR REPLACE FUNCTION log_customer_update()
RETURNS TRIGGER AS $$
DECLARE
    v_user_email VARCHAR(255);
    v_user_role VARCHAR(50);
BEGIN
    SELECT email, role INTO v_user_email, v_user_role FROM get_user_info();
    
    INSERT INTO audit_logs (user_email, user_role, action, table_name, record_id, timestamp, ip_address)
    VALUES (v_user_email, v_user_role, 'UPDATE_CUSTOMER', 'customers', NEW.customer_id, NOW(), inet_client_addr()::VARCHAR(45));
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_log_customer_update ON customers;
CREATE TRIGGER trigger_log_customer_update 
    AFTER UPDATE ON customers 
    FOR EACH ROW 
    EXECUTE FUNCTION log_customer_update();


-- 4. TRIGGER CUSTOMERS DELETE
CREATE OR REPLACE FUNCTION log_customer_delete()
RETURNS TRIGGER AS $$
DECLARE
    v_user_email VARCHAR(255);
    v_user_role VARCHAR(50);
BEGIN
    SELECT email, role INTO v_user_email, v_user_role FROM get_user_info();
    
    INSERT INTO audit_logs (user_email, user_role, action, table_name, record_id, timestamp, ip_address)
    VALUES (v_user_email, v_user_role, 'DELETE_CUSTOMER', 'customers', OLD.customer_id, NOW(), inet_client_addr()::VARCHAR(45));
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_log_customer_delete ON customers;
CREATE TRIGGER trigger_log_customer_delete 
    BEFORE DELETE ON customers 
    FOR EACH ROW 
    EXECUTE FUNCTION log_customer_delete();

-- ========================================
-- TEST FINAL
-- ========================================

-- Test : Update un account
UPDATE accounts SET balance = balance + 100 WHERE account_id = 1;

-- Vérifier les logs
SELECT 
    log_id,
    user_email,
    user_role,
    action,
    table_name,
    record_id,
    timestamp
FROM audit_logs
ORDER BY timestamp DESC
LIMIT 5;