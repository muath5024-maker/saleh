import { redirect } from 'next/navigation';
import { headers } from 'next/headers';
import { extractStoreSlug } from '@/lib/utils/store-slug';

export default async function Home() {
  const headersList = await headers();
  const host = headersList.get('host') || '';
  const slug = extractStoreSlug(host);

  // If it's a store subdomain, redirect to store page
  if (slug) {
    redirect(`/store/${slug}`);
  }

  // Otherwise, redirect to onboarding
  redirect('/onboarding');
}
