-- Migration to add app_feedback table
CREATE TABLE IF NOT EXISTS app_feedback (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID,
    user_email TEXT,
    subject TEXT NOT NULL,
    message TEXT NOT NULL,
    device_info TEXT,
    app_version TEXT,
    status TEXT DEFAULT 'new' CHECK (status IN ('new', 'read', 'resolved')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS
ALTER TABLE app_feedback ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to insert feedback
CREATE POLICY "Authenticated users can insert feedback"
ON app_feedback FOR INSERT
WITH CHECK (auth.role() = 'authenticated');

-- Allow anon users to insert feedback (if critical)
GRANT INSERT ON app_feedback TO anon;
CREATE POLICY "Anon users can insert feedback"
ON app_feedback FOR INSERT
WITH CHECK (true);

-- Allow admins to read/update (Assuming admin role logic or service role, defaulting to none for others)
-- No Read policy for public users.
