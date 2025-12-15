/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // Enable wildcard subdomain routing
  async rewrites() {
    return [
      {
        source: '/:path*',
        destination: '/:path*',
      },
    ];
  },
  // Handle subdomain routing
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'X-Store-Slug',
            value: ':slug',
          },
        ],
      },
    ];
  },
};

module.exports = nextConfig;
