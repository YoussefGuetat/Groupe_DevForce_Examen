CREATE TABLE profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('admin', 'analyst', 'customer_service', 'client')),
  created_at TIMESTAMP DEFAULT now()
); 

-- Admin
INSERT INTO profiles (id, role)
VALUES ('9e52663e-e859-4810-94ce-23680e72120f', 'admin');  

-- Client
INSERT INTO profiles (id, role)
VALUES ('be450d0a-9d1c-4283-9b59-02968da1ddc0', 'client');  

INSERT INTO profiles (id, role)
VALUES ('27054242-0109-45ba-ac96-1de6be340122', 'client');  

--Analyst
INSERT INTO profiles (id, role)
VALUES ('3b64e2ca-194a-44ce-a25c-f50c4b303a29', 'analyst'); 

-- Customer Service
INSERT INTO profiles (id, role)
VALUES ('eeacbd92-4ba0-450b-8c59-24a5c11d79f8', 'customer_service');


