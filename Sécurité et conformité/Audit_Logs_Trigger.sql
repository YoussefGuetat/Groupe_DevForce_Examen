-- ========================================
-- 1. TABLE AUDIT_LOGS
-- ========================================

CREATE TABLE IF NOT EXISTS audit_logs (
    log_id SERIAL PRIMARY KEY,
    user_id INTEGER,
    user_email VARCHAR(255),
    user_role VARCHAR(50),
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    record_id INTEGER,
    timestamp TIMESTAMP DEFAULT NOW(),
    ip_address VARCHAR(45)
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_email ON audit_logs(user_email);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_logs_table ON audit_logs(table_name);
CREATE INDEX IF NOT EXISTS idx_audit_logs_timestamp ON audit_logs(timestamp);

-- ========================================
-- 2. FONCTION HELPER POUR RÉCUPÉRER INFO USER
-- ========================================

CREATE OR REPLACE FUNCTION get_user_info()
RETURNS TABLE(email VARCHAR(255), role VARCHAR(50)) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.email::VARCHAR(255), 
        COALESCE(ur.role, 'unknown')::VARCHAR(50)
    FROM auth.users u
    LEFT JOIN user_roles ur ON u.id = ur.user_id
    WHERE u.id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- 3. TRIGGERS POUR TABLE ACCOUNTS
-- ========================================

-- 3A. TRIGGER UPDATE ACCOUNTS
CREATE OR REPLACE FUNCTION log_account_update()
RETURNS TRIGGER AS $$
DECLARE
    v_user_email VARCHAR(255);
    v_user_role VARCHAR(50);
BEGIN
    -- Récupérer l'utilisateur actuel
    SELECT email, role INTO v_user_email, v_user_role FROM get_user_info();
    
    -- Logger l'action
    INSERT INTO audit_logs (
        user_id, 
        user_email, 
        user_role, 
        action, 
        table_name, 
        record_id, 
        timestamp, 
        ip_address
    ) VALUES (
        auth.uid()::INTEGER, 
        v_user_email, 
        v_user_role, 
        'UPDATE_ACCOUNT', 
        'accounts', 
        NEW.account_id, 
        NOW(), 
        inet_client_addr()::VARCHAR(45)
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_log_account_update ON accounts;
CREATE TRIGGER trigger_log_account_update 
    AFTER UPDATE ON accounts 
    FOR EACH ROW 
    EXECUTE FUNCTION log_account_update();

-- 3B. TRIGGER DELETE ACCOUNTS
CREATE OR REPLACE FUNCTION log_account_delete()
RETURNS TRIGGER AS $$
DECLARE
    v_user_email VARCHAR(255);
    v_user_role VARCHAR(50);
BEGIN
    SELECT email, role INTO v_user_email, v_user_role FROM get_user_info();
    
    INSERT INTO audit_logs (
        user_id, 
        user_email, 
        user_role, 
        action, 
        table_name, 
        record_id, 
        timestamp, 
        ip_address
    ) VALUES (
        auth.uid()::INTEGER, 
        v_user_email, 
        v_user_role, 
        'DELETE_ACCOUNT', 
        'accounts', 
        OLD.account_id, 
        NOW(), 
        inet_client_addr()::VARCHAR(45)
    );
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_log_account_delete ON accounts;
CREATE TRIGGER trigger_log_account_delete 
    BEFORE DELETE ON accounts 
    FOR EACH ROW 
    EXECUTE FUNCTION log_account_delete();

-- ========================================
-- 4. TRIGGERS POUR TABLE CUSTOMERS
-- ========================================

-- 4A. TRIGGER UPDATE CUSTOMERS
CREATE OR REPLACE FUNCTION log_customer_update()
RETURNS TRIGGER AS $$
DECLARE
    v_user_email VARCHAR(255);
    v_user_role VARCHAR(50);
BEGIN
    SELECT email, role INTO v_user_email, v_user_role FROM get_user_info();
    
    INSERT INTO audit_logs (
        user_id, 
        user_email, 
        user_role, 
        action, 
        table_name, 
        record_id, 
        timestamp, 
        ip_address
    ) VALUES (
        auth.uid()::INTEGER, 
        v_user_email, 
        v_user_role, 
        'UPDATE_CUSTOMER', 
        'customers', 
        NEW.customer_id, 
        NOW(), 
        inet_client_addr()::VARCHAR(45)
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_log_customer_update ON customers;
CREATE TRIGGER trigger_log_customer_update 
    AFTER UPDATE ON customers 
    FOR EACH ROW 
    EXECUTE FUNCTION log_customer_update();

-- 4B. TRIGGER DELETE CUSTOMERS
CREATE OR REPLACE FUNCTION log_customer_delete()
RETURNS TRIGGER AS $$
DECLARE
    v_user_email VARCHAR(255);
    v_user_role VARCHAR(50);
BEGIN
    SELECT email, role INTO v_user_email, v_user_role FROM get_user_info();
    
    INSERT INTO audit_logs (
        user_id, 
        user_email, 
        user_role, 
        action, 
        table_name, 
        record_id, 
        timestamp, 
        ip_address
    ) VALUES (
        auth.uid()::INTEGER, 
        v_user_email, 
        v_user_role, 
        'DELETE_CUSTOMER', 
        'customers', 
        OLD.customer_id, 
        NOW(), 
        inet_client_addr()::VARCHAR(45)
    );
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_log_customer_delete ON customers;
CREATE TRIGGER trigger_log_customer_delete 
    BEFORE DELETE ON customers 
    FOR EACH ROW 
    EXECUTE FUNCTION log_customer_delete();

-- ========================================
-- 5. FONCTION POUR LOGGER LES CONSULTATIONS
-- ========================================

CREATE OR REPLACE FUNCTION log_customer_view(p_customer_id INTEGER)
RETURNS SETOF customers AS $$
DECLARE
    v_user_email VARCHAR(255);
    v_user_role VARCHAR(50);
BEGIN
    SELECT email, role INTO v_user_email, v_user_role FROM get_user_info();
    
    INSERT INTO audit_logs (
        user_id, 
        user_email, 
        user_role, 
        action, 
        table_name, 
        record_id, 
        timestamp, 
        ip_address
    ) VALUES (
        auth.uid()::INTEGER, 
        v_user_email, 
        v_user_role, 
        'VIEW_CUSTOMER', 
        'customers', 
        p_customer_id, 
        NOW(), 
        inet_client_addr()::VARCHAR(45)
    );
    
    RETURN QUERY SELECT * FROM customers WHERE customer_id = p_customer_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- 6. EXEMPLES D'UTILISATION
-- ========================================

-- Pour consulter un client et logger l'action :
-- SELECT * FROM log_customer_view(1);

-- Pour voir les 20 dernières actions :
-- SELECT * FROM audit_logs ORDER BY timestamp DESC LIMIT 20;

-- Pour voir les actions d'un utilisateur spécifique :
-- SELECT * FROM audit_logs WHERE user_email = 'admin@digitalbank.fr';

-- Pour voir toutes les suppressions :
-- SELECT * FROM audit_logs WHERE action LIKE 'DELETE%';

-- ========================================
-- FIN DU SCRIPT
-- ========================================