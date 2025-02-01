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
        { email: 'customer1@example.com', password: 'password' },
        { email: 'customer2@example.com', password: 'password' },
        { email: 'agent1@example.com', password: 'password' },
        { email: 'agent2@example.com', password: 'password' },
        { email: 'supervisor@example.com', password: 'password'},
        { email: 'hr@example.com', password: 'password' }
    ]

    for (const user of users) {
        const { data: createdUser, error } = await supabase.auth.signUp({
            email: user.email,
            password: user.password
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