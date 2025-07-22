#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Setup monorepo..."

# Instala deps da raiz
[ -f package.json ] && npm install

# Workspaces (apps/* e packages/*)
for dir in apps/* packages/*; do
  if [ -f "$dir/package.json" ]; then
    echo "📦 npm install ($dir)"
    (cd "$dir" && npm install)
  fi
done

# Prisma (se existir)
if [ -d apps/api/prisma ]; then
  echo "🗃️ Prisma migrate/generate"
  (cd apps/api && npx prisma migrate dev --name init || true)
  (cd apps/api && npx prisma generate)
fi

# SDK OpenAPI (se docs e pkg existirem)
if [ -f docs/api-spec.yml ] && [ -d packages/sdk ]; then
  echo "🧬 Gerando SDK TS"
  (cd packages/sdk && npx openapi-typescript-codegen --input ../../docs/api-spec.yml --output .)
fi

echo "✅ Tudo pronto!"

