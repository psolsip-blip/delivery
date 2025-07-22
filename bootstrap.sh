#!/usr/bin/env bash
set -e

# 0. Pastas básicas
mkdir -p apps/{api,mobile,admin-web} packages/{ui,config,sdk} infra/{compose,docker/api} docs .github/workflows

# 1. .gitignore
cat > .gitignore <<'EOF'
node_modules/
.npm/
*.log
.env
.env.*
.expo/
.expo-shared/
build/
dist/
.next/
.coverage/
.DS_Store
prisma/*.db
EOF

# 2. .editorconfig
cat > .editorconfig <<'EOF'
root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 2
insert_final_newline = true
trim_trailing_whitespace = true
EOF

# 3. LICENSE (MIT exemplo)
cat > LICENSE <<'EOF'
MIT License
Copyright (c) 2025 Marcos Rosa
Permission is hereby granted, free of charge, to any person obtaining a copy...
EOF

# 4. README
cat > README.md <<'EOF'
# Delivery App Monorepo
Veja o documento no repositório para detalhes da stack e como rodar.
EOF

# 5. package.json raiz
cat > package.json <<'EOF'
{
  "private": true,
  "workspaces": ["apps/*", "packages/*"],
  "scripts": {
    "dev:api": "npm --workspace apps/api run start:dev",
    "dev:mobile": "npm --workspace apps/mobile run start",
    "dev:admin": "npm --workspace apps/admin-web run dev",
    "lint": "eslint . --ext .ts,.tsx",
    "build": "echo build all"
  }
}
EOF

# 6. docker-compose
cat > infra/compose/docker-compose.yml <<'EOF'
version: "3.9"
services:
  api:
    build: ../docker/api
    ports:
      - "3000:3000"
    env_file:
      - ../docker/api/.env
    depends_on:
      - db
      - redis
  db:
    image: postgres:15
    environment:
      POSTGRES_USER: delivery
      POSTGRES_PASSWORD: delivery
      POSTGRES_DB: delivery
    ports:
      - "5432:5432"
    volumes:
      - db_data:/var/lib/postgresql/data
  redis:
    image: redis:7
    ports:
      - "6379:6379"
volumes:
  db_data:
EOF

# 7. Dockerfile API
cat > infra/docker/api/Dockerfile <<'EOF'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev || npm install --omit=dev
COPY . .
CMD ["node", "dist/main.js"]
EOF

# 8. .env exemplo
cat > infra/docker/api/.env <<'EOF'
DATABASE_URL=postgresql://delivery:delivery@db:5432/delivery?schema=public
JWT_SECRET=supersecret
OPENPIX_API_KEY=COLOQUE_AQUI
GOOGLE_MAPS_KEY=COLOQUE_AQUI
EOF

echo "✅ Estrutura criada. Agora rode scripts/setup.sh para instalar deps."
