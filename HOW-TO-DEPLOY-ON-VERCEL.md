##Flutter Web on Vercel.com (free hosting/authentication/database)*

##tl;dr

You can host a Flutter web app on Vercel.com using a basic NextJS landing page that has a Auth0 login button and use Vercel's Blob storage as a free database.

This is all free within limits.

This is NOT a complete step-by-step guide.

##Setup

Put the built Flutter Web app in public/app of the new NextJS project. The HTML and code may look different if you use dependencies such as Tailwind.css.

##NextJS Code

The NextJS landing page.
src/app/page.tsx
```typescript
'use client'

import { useSession, signIn, signOut } from 'next-auth/react'
import { useRouter } from 'next/navigation'

export default function Home() {
  const { data: session } = useSession()
  const router = useRouter()

  if (session) {
    return (
      <div style={{ display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
        <p>Welcome, {session.user?.name ?? 'user'}!</p>
        <button onClick={() => router.push('/app/index.html')}>Go to App</button>
        <br />
        <button onClick={() => signOut({ callbackUrl: '/' })}>Sign out</button>
      </div>
    )
  }

  return (
    <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
      <button onClick={() => signIn('auth0')}>Sign in with Auth0</button>
    </div>
  )
}
```

Ensure the other pages / Flutter app is protected by Auth0.
src/middleware.ts
```typescript
import { withAuth } from "next-auth/middleware"

export default withAuth({
  callbacks: {
    authorized: ({ token }) => !!token,
  },
})

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api/auth (API routes for authentication)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - / (the homepage)
     */
    '/((?!api/auth|_next/static|_next/image|favicon.ico|$).+)',
  ],
}
```

Implement the Auth0 login route,
src/app/api/auth/[...nextauth]/route.ts
```typescript
import NextAuth from 'next-auth';
import { authOptions } from '@/lib/auth';

const handler = NextAuth(authOptions);

export { handler as GET, handler as POST };
```

Implement the logic to authorize users (very simplified example - just checks their email is in the list of authorized users).

src/lib/auth.ts
```typescript
import { type NextAuthOptions } from 'next-auth';
import Auth0Provider from 'next-auth/providers/auth0';

if (!process.env.AUTH0_CLIENT_ID) {
  throw new Error('Missing AUTH0_CLIENT_ID environment variable');
}

if (!process.env.AUTH0_CLIENT_SECRET) {
  throw new Error('Missing AUTH0_CLIENT_SECRET environment variable');
}

if (!process.env.AUTH0_ISSUER) {
  throw new Error('Missing AUTH0_ISSUER environment variable');
}

const allowedEmails = ['someone@gmail.com', 'another-person@gmail.com']; // Authorized Users

export const authOptions: NextAuthOptions = {
  providers: [
    Auth0Provider({
      clientId: process.env.AUTH0_CLIENT_ID,
      clientSecret: process.env.AUTH0_CLIENT_SECRET,
      issuer: process.env.AUTH0_ISSUER,
    }),
  ],
  secret: process.env.NEXTAUTH_SECRET,
  callbacks: {
    async signIn({ user }) {
      if (user.email && allowedEmails.includes(user.email)) {
        return true;
      }
      return false;
    },
    async jwt({ token, account }) {
      if (account) {
        token.accessToken = account.access_token;
      }
      return token;
    },
    async session({ session, token }) {
      // Add property to session, like an access_token from a provider.
      // @ts-expect-error - We are intentionally extending the session object. Comment required by linter.
      session.accessToken = token.accessToken;
      return session;
    },
  },
};
```

##WARNING
This is NOT production level code, an attacker could arbitrarily save/load multiple Blobs or the maximum size allowed by Vercel. 
The Blob storage on Vercel is not private but you can obscure URLs by hashing it with a server secret. Additionally, you could encrypt the data (not shown here). To use Blog storage uncomment the API code call in workout_provider.dart

Implement the database API - user data is stored in /user/<email hash>
src/app/api/blog/route.ts
```typescript
import { put, list } from '@vercel/blob';
import { NextResponse } from 'next/server';
import { getServerSession } from 'next-auth/next';
import { authOptions } from '@/lib/auth';
import { createHmac } from 'crypto';

function getFilename(email: string) {
  if (!process.env.BLOB_FILENAME_SECRET) {
    throw new Error('Missing BLOB_FILENAME_SECRET environment variable');
  }
  const hmac = createHmac('sha256', process.env.BLOB_FILENAME_SECRET);
  hmac.update(email);
  return `${hmac.digest('hex')}.json`;
}

export async function POST(request: Request) {
  const session = await getServerSession(authOptions);
  if (!session || !session.user || !session.user.email) {
    return new Response('Unauthorized', { status: 401 });
  }

  const { email } = session.user;
  const filename = getFilename(email);
  const data = await request.json();

  const blob = await put(`user/${filename}`, JSON.stringify(data), {
    access: 'public',
    allowOverwrite: true,
  });

  return NextResponse.json(blob);
}

export async function GET(_request: Request) {
  const session = await getServerSession(authOptions);
  if (!session || !session.user || !session.user.email) {
    return new Response('Unauthorized', { status: 401 });
  }

  const { email } = session.user;
  const filename = getFilename(email);

  try {
    const { blobs } = await list({ prefix: 'user/' });
    const userBlob = blobs.find((blob) => blob.pathname === `user/${filename}`);

    if (!userBlob) {
      return NextResponse.json({});
    }

    const response = await fetch(userBlob.url);
    const data = await response.json();

    return NextResponse.json(data);
  } catch (_error: unknown) {
    return new Response('Error fetching data', { status: 500 });
  }
}
```

On your Vercel project on vercel.com you need these environment variables set, also in .env.local (replace with urls with "http://localhost:3000")

/.env.local
```
BLOB_READ_WRITE_TOKEN=tokenstring
BLOB_FILENAME_SECRET=secretstringforhashing
AUTH0_CLIENT_ID=clientidstring
AUTH0_CLIENT_SECRET=clientsecretstring
AUTH0_ISSUER=https://your-domain.auth0.com
AUTH0_DOMAIN=https://your-domain.auth0.com
NEXTAUTH_SECRET=secretstringfornextauth
AUTH0_BASE_URL=https://your-domain.vercel.app
NEXTAUTH_URL=https://your-domain.vercel.app
```

##Deployment

Besides standard setting up on auth0.com and vercel.com to get the environment variables, you need to create a Blob storage in Vercel.

You will need to setup Git/Github to connect your project to Vercel.

Name this NextJS project directory called ~/what-ever/fitness-vibe-nextjs
Have the Flutter project directory called ~/what-ever/fitness-vibe

Run the shell command from the Flutter project directory. You may need to adjust it for Windows (non-Unix like environment).

```
./release.sh
```

This will build the Flutter project and copy it to the NextJS project, then use git to push the changes to the Vercel project.
If your git user name and email address are the same as that used by Vercel, then this will trigger a deployment on Vercel.
