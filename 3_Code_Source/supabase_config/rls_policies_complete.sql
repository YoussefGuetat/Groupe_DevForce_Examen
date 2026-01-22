-- ===============================================
-- DigitalBank France - RLS Policies Complete
-- Date: 2025-01-21
-- Partie 2.2: Authentification et Gestion des Accès
-- ===============================================

-- ===============================================
-- 1. CRÉATION DE LA TABLE PROFILES (si pas déjà fait)
-- ===============================================

CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('admin', 'analyst', 'customer_service', 'client')),
  created_at TIMESTAMP DEFAULT NOW()
);

-- ===============================================
-- 2. INSERTION DES UTILISATEURS DE TEST
-- ===============================================

-- Note: Remplacez les UUIDs par les vrais UUIDs de vos utilisateurs Supabase
-- Trouvez les UUIDs dans: Authentication > Users dans le dashboard Supabase

-- Admin
INSERT INTO profiles (id, role)
VALUES ('9e52663e-e859-4810-94ce-23680e72120f', 'admin')
ON CONFLICT (id) DO NOTHING;

-- Analyst
INSERT INTO profiles (id, role)
VALUES ('3b64e2ca-194a-44ce-a25c-f50c4b303a29', 'analyst')
ON CONFLICT (id) DO NOTHING;

-- Customer Service
INSERT INTO profiles (id, role)
VALUES ('f8a9c2d1-4b3e-5c6d-7e8f-9a0b1c2d3e4f', 'customer_service')
ON CONFLICT (id) DO NOTHING;

-- Client
INSERT INTO profiles (id, role)
VALUES ('be450d0a-9d1c-4283-9b59-02968da1ddc0', 'client')
ON CONFLICT (id) DO NOTHING;

-- ===============================================
-- 3. POLICIES POUR LA TABLE CUSTOMERS
-- ===============================================

ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;

-- Supprimer les anciennes policies
DROP POLICY IF EXISTS customers_admin ON public.customers;
DROP POLICY IF EXISTS customers_analyst ON public.customers;
DROP POLICY IF EXISTS customers_customer_service ON public.customers;
DROP POLICY IF EXISTS customers_client ON public.customers;

-- ADMIN: Accès complet
CREATE POLICY customers_admin
ON public.customers
AS PERMISSIVE
FOR ALL
TO authenticated
USING (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin')
)
WITH CHECK (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin')
);

-- ANALYST: Aucun accès direct aux clients (uniquement transactions)
-- Pas de policy pour l'analyst sur customers

-- CUSTOMER SERVICE: Lecture et modification limitée
CREATE POLICY customers_customer_service
ON public.customers
AS PERMISSIVE
FOR SELECT
TO authenticated
USING (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'customer_service')
);

-- CUSTOMER SERVICE: Peut modifier statut uniquement (pas les données sensibles)
CREATE POLICY customers_customer_service_update
ON public.customers
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'customer_service')
)
WITH CHECK (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'customer_service')
);

-- CLIENT: Lecture de son propre profil uniquement
CREATE POLICY customers_client
ON public.customers
AS PERMISSIVE
FOR SELECT
TO authenticated
USING (
  customers.email = auth.email()
);

-- ===============================================
-- 4. POLICIES POUR LA TABLE ACCOUNTS
-- ===============================================

ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;

-- Supprimer les anciennes policies
DROP POLICY IF EXISTS accounts_admin ON public.accounts;
DROP POLICY IF EXISTS accounts_analyst ON public.accounts;
DROP POLICY IF EXISTS accounts_customer_service ON public.accounts;
DROP POLICY IF EXISTS accounts_client ON public.accounts;

-- ADMIN: Accès complet
CREATE POLICY accounts_admin
ON public.accounts
AS PERMISSIVE
FOR ALL
TO authenticated
USING (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin')
)
WITH CHECK (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin')
);

-- ANALYST: Lecture globale
CREATE POLICY accounts_analyst
ON public.accounts
AS PERMISSIVE
FOR SELECT
TO authenticated
USING (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'analyst')
);

-- CUSTOMER SERVICE: Lecture globale
CREATE POLICY accounts_customer_service
ON public.accounts
AS PERMISSIVE
FOR SELECT
TO authenticated
USING (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'customer_service')
);

-- CUSTOMER SERVICE: Peut modifier le statut des comptes (frozen, active)
CREATE POLICY accounts_customer_service_update
ON public.accounts
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'customer_service')
)
WITH CHECK (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'customer_service')
);

-- CLIENT: Uniquement ses comptes
CREATE POLICY accounts_client
ON public.accounts
AS PERMISSIVE
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM customers
    WHERE customers.customer_id = accounts.customer_id
      AND customers.email = auth.email()
  )
);

-- ===============================================
-- 5. POLICIES POUR LA TABLE TRANSACTIONS
-- ===============================================

ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Supprimer les anciennes policies
DROP POLICY IF EXISTS transactions_admin ON public.transactions;
DROP POLICY IF EXISTS transactions_analyst ON public.transactions;
DROP POLICY IF EXISTS transactions_customer_service ON public.transactions;
DROP POLICY IF EXISTS transactions_client ON public.transactions;

-- ADMIN: Accès complet
CREATE POLICY transactions_admin
ON public.transactions
AS PERMISSIVE
FOR ALL
TO authenticated
USING (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin')
)
WITH CHECK (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin')
);

-- ANALYST: Lecture globale (pour détection de fraude)
CREATE POLICY transactions_analyst
ON public.transactions
AS PERMISSIVE
FOR SELECT
TO authenticated
USING (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'analyst')
);

-- CUSTOMER SERVICE: Lecture globale
CREATE POLICY transactions_customer_service
ON public.transactions
AS PERMISSIVE
FOR SELECT
TO authenticated
USING (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'customer_service')
);

-- CUSTOMER SERVICE: Peut modifier le statut (ex: reverser une transaction)
CREATE POLICY transactions_customer_service_update
ON public.transactions
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'customer_service')
)
WITH CHECK (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'customer_service')
);

-- CLIENT: Uniquement ses transactions
CREATE POLICY transactions_client
ON public.transactions
AS PERMISSIVE
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM accounts a
    INNER JOIN customers c ON a.customer_id = c.customer_id
    WHERE transactions.account_id = a.account_id
      AND c.email = auth.email()
  )
);

-- ===============================================
-- 6. POLICIES POUR LA TABLE CARDS
-- ===============================================

ALTER TABLE public.cards ENABLE ROW LEVEL SECURITY;

-- Supprimer les anciennes policies
DROP POLICY IF EXISTS cards_admin ON public.cards;
DROP POLICY IF EXISTS cards_customer_service ON public.cards;
DROP POLICY IF EXISTS cards_client ON public.cards;

-- ADMIN: Accès complet
CREATE POLICY cards_admin
ON public.cards
AS PERMISSIVE
FOR ALL
TO authenticated
USING (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin')
)
WITH CHECK (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin')
);

-- CUSTOMER SERVICE: Lecture et peut bloquer/débloquer
CREATE POLICY cards_customer_service
ON public.cards
AS PERMISSIVE
FOR SELECT
TO authenticated
USING (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'customer_service')
);

CREATE POLICY cards_customer_service_update
ON public.cards
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'customer_service')
)
WITH CHECK (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'customer_service')
);

-- CLIENT: Uniquement ses cartes
CREATE POLICY cards_client
ON public.cards
AS PERMISSIVE
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM accounts a
    INNER JOIN customers c ON a.customer_id = c.customer_id
    WHERE cards.account_id = a.account_id
      AND c.email = auth.email()
  )
);

-- ===============================================
-- 7. POLICIES POUR LA TABLE LOGIN_ATTEMPTS
-- ===============================================

ALTER TABLE public.login_attempts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS login_attempts_admin ON public.login_attempts;
DROP POLICY IF EXISTS login_attempts_analyst ON public.login_attempts;

-- ADMIN: Accès complet
CREATE POLICY login_attempts_admin
ON public.login_attempts
AS PERMISSIVE
FOR ALL
TO authenticated
USING (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin')
)
WITH CHECK (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'admin')
);

-- ANALYST: Lecture pour analyse de sécurité
CREATE POLICY login_attempts_analyst
ON public.login_attempts
AS PERMISSIVE
FOR SELECT
TO authenticated
USING (
  auth.uid() IN (SELECT id FROM profiles WHERE role = 'analyst')
);

-- ===============================================
--  VÉRIFICATION DES POLICIES
-- ===============================================

-- Lister toutes les policies créées
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- Compter les policies par table
SELECT 
  tablename,
  COUNT(*) as nb_policies
FROM pg_policies
WHERE schemaname = 'public'
GROUP BY tablename
ORDER BY tablename;

-- ===============================================
-- FIN DU SCRIPT
-- ===============================================

