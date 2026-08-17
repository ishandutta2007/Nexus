docker stop nexus
docker rm nexus
docker build -t nexus .
docker run -d --name nexus -p 20128:20128 --env-file .env -v nexus-data:/app/data nexus