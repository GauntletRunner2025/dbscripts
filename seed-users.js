import { createClient } from '@supabase/supabase-js'

if (!process.env.VITE_SUPABASE_URL || !process.env.VITE_SUPABASE_ANON_KEY) {
    throw new Error('Missing required environment variables VITE_SUPABASE_URL or VITE_SUPABASE_ANON_KEY')
}

const supabase = createClient(
    process.env.VITE_SUPABASE_URL,
    process.env.VITE_SUPABASE_ANON_KEY
)

async function seedUsers() {
    const users = [
        { email: 'customer1@example.com', password: 'password123', role: 'customer' },
        { email: 'customer2@example.com', password: 'password123', role: 'customer' },
        { email: 'agent1@example.com', password: 'password123', role: 'agent' },
        { email: 'agent2@example.com', password: 'password123', role: 'agent' },
        { email: 'supervisor@example.com', password: 'password123', role: 'supervisor' },
        { email: 'hr@example.com', password: 'password123', role: 'hr' }
    ]

    for (const user of users) {
        const { data: createdUser, error } = await supabase.auth.signUp({
            email: user.email,
            password: user.password,
            options: {
                data: {
                    role: user.role
                }
            }
        })

        if (error) {
            console.error(`Error creating user ${user.email}:`, error.message)
            continue
        }

        if (!createdUser) {
            console.error(`No user data returned for ${user.email}`)
            continue
        }

        console.log(`User created: ${user.email} with role: ${user.role}`)
    }
}

seedUsers()
    .catch(error => {
        console.error('Seed script failed:', error)
        process.exit(1)
    })