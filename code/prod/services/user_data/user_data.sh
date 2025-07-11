#!/bin/bash
sudo apt update
sudo apt install -y python3 python3-pip python3-virtualenv nginx jq

GitRepoURL="https://github.com/clahi/Recipe-sharing.git"

git clone $GitRepoURL
cp -r $(echo $GitRepoURL | sed 's/.*\///' | sed 's/\.git//')/code/backend . ; rm -rf $(echo $GitRepoURL | sed 's/.*\///' | sed 's/\.git//') ; cd backend

sed -i "s/SELECTED_REGION/$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')/g" main.py

# Create an Nginx configuration file
cat > /etc/nginx/sites-available/fastapi <<EOF
server {
listen 80;
server_name ~.;
location / {
proxy_pass http://localhost:8000;
}
}
EOF

sudo ln -s /etc/nginx/sites-available/fastapi /etc/nginx/sites-enabled/
sudo systemctl restart nginx
virtualenv .venv
source .venv/bin/activate
pip install -r requirements.txt
python3 -m uvicorn main:app &

# #!/bin/bash
# cat > index.html <<EOF
# <h1>Hello</h1>
# <h2>This is the environment </h2>
# <p>DB address: </p>
# <p>DB port: </p>

# EOF

# nohup busybox httpd -f -p 8080 &