import prisma from '@/lib/prisma';

export const dynamic = 'force-dynamic';

export default async function Home() {
  const messages = await prisma.message.findMany();

  return (
    <div className='flex flex-col items-center justify-center h-screen'>
      <h1 className='text-6xl font-bold'>Hey</h1>
      <div className='flex flex-col gap-4 max-w[400px] mx-auto'>
        {
          messages.length === 0 ? (
            <div className='border p-4'>No messages yet.</div>
          ) :
            messages.map((message) => (
              <div key={message.id} className='border p-4'>
                {message.text}
              </div>
            ))
        }
      </div>
    </div>
  );
}
