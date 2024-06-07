
#!/bin/bash
REMOTE_USER=$1
REMOTE_HOST=$2
SSH_PRIVATE_KEY=$3
TARGET_DIRECTORY=$4
SSH_PORT=${5:-22}
OWNER=${5:-www-data}
COMMANDS=$6

mkdir -p /root/.ssh
ssh-keyscan -H "$REMOTE_HOST" >> /root/.ssh/known_hosts

if [ -z "$SSH_PRIVATE_KEY" ];
then
	echo $'\n' "------ DEPLOY KEY NOT SET YET! ----------------" $'\n'
	exit 1
else
	printf '%b\n' "$SSH_PRIVATE_KEY" > /root/.ssh/id_rsa
	chmod 400 /root/.ssh/id_rsa

	echo $'\n' "------ CONFIG SUCCESSFUL! ---------------------" $'\n'
fi

if [ ! -z "$SSH_PORT" ];
then
  printf "Host %b\n\tPort %b\n" "$REMOTE_HOST" "$SSH_PORT" > /root/.ssh/config
	ssh-keyscan -p $SSH_PORT -H "$REMOTE_HOST" >> /root/.ssh/known_hosts
fi

rsync --progress -avzh \
	--exclude='.git/' \
	--exclude='.git*' \
	--exclude='.editorconfig' \
	--exclude='.styleci.yml' \
	--exclude='.idea/' \
	--exclude='Dockerfile' \
	--exclude='readme.md' \
	--exclude='README.md' \
	-e "ssh -i /root/.ssh/id_rsa" \
	. $REMOTE_USER@$REMOTE_HOST:$TARGET_DIRECTORY

if [ $? -eq 0 ]
then
	echo $'\n' "------ SYNC SUCCESSFUL! -----------------------" $'\n'
	# echo $'\n' "------ RELOADING PERMISSION -------------------" $'\n'

	# ssh -i /root/.ssh/id_rsa -t $REMOTE_USER@$REMOTE_HOST "sudo chown -R $OWNER:$OWNER $TARGET_DIRECTORY"
	# ssh -i /root/.ssh/id_rsa -t $REMOTE_USER@$REMOTE_HOST "sudo chmod 775 -R $TARGET_DIRECTORY"
	# ssh -i /root/.ssh/id_rsa -t $REMOTE_USER@$REMOTE_HOST "sudo chmod 777 -R $TARGET_DIRECTORY/storage"
	# ssh -i /root/.ssh/id_rsa -t $REMOTE_USER@$REMOTE_HOST "sudo chmod 777 -R $TARGET_DIRECTORY/public"
	ssh -i /root/.ssh/id_rsa -t $REMOTE_USER@$REMOTE_HOST "
	    cd $TARGET_DIRECTORY &&
	    php artisan cache:clear &&
	    php artisan config:clear &&
	    php artisan route:clear &&
	    php artisan view:clear &&
	    php artisan config:cache &&
	    php artisan route:cache &&
	    php artisan view:cache &&
	    composer dump-autoload -o
	"
	if [ ! -z "$COMMANDS" ];
	then
		ssh -i /root/.ssh/id_rsa -t $REMOTE_USER@$REMOTE_HOST "cd $TARGET_DIRECTORY && $COMMANDS"
	fi

	echo $'\n' "------ CONGRATS! DEPLOY SUCCESSFUL!!! ---------" $'\n'
	exit 0
else
	echo $'\n' "------ DEPLOY FAILED! -------------------------" $'\n'
	exit 1
fi
