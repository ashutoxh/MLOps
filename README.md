# Final Project

## Steps

cd object-detection-react-app && docker build . -t ashutoxh/object-detection-react-app
cd object-detection-react-app && docker push ashutoxh/object-detection-react-app
cd yolo-v5-flask-app && docker build . -t ashutoxh/yolo-v5-flask-app

cd yolo-v5-flask-app && docker push ashutoxh/yolo-v5-flask-app
cd depth-anything-flask-app && docker build . -t ashutoxh/depth-anything-flask-app
cd depth-anything-flask-app && docker push ashutoxh/depth-anything-flask-app

In yolo, had to change 127.0.0.0 to 0.0.0.0

## dev build

docker build \
-f depth-anything-flask-app/Dockerfile \
-t 680604704378.dkr.ecr.us-east-1.amazonaws.com/mlops/depth-anything-flask-app:dev \
./depth-anything-flask-app

docker build \
-f object-detection-react-app/Dockerfile \
-t 680604704378.dkr.ecr.us-east-1.amazonaws.com/mlops/object-detection-react-app:dev \
./object-detection-react-app

docker build \
-f yolo-v5-flask-app/Dockerfile \
-t 680604704378.dkr.ecr.us-east-1.amazonaws.com/mlops/yolo-v5-flask-app:dev \
./yolo-v5-flask-app

## login

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 680604704378.dkr.ecr.us-east-1.amazonaws.com

## dev push
docker push 680604704378.dkr.ecr.us-east-1.amazonaws.com/mlops/depth-anything-flask-app:dev
docker push 680604704378.dkr.ecr.us-east-1.amazonaws.com/mlops/object-detection-react-app:dev
docker push 680604704378.dkr.ecr.us-east-1.amazonaws.com/mlops/yolo-v5-flask-app:dev

## prod push 
docker build \
  -f depth-anything-flask-app/Dockerfile \
  -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/mlops/depth-anything-flask-app:prod \
  ./depth-anything-flask-app

docker build \
  -f object-detection-react-app/Dockerfile \
  -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/mlops/object-detection-react-app:prod \
  ./object-detection-react-app

docker build \
  -f yolo-v5-flask-app/Dockerfile \
  -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/mlops/yolo-v5-flask-app:prod \
  ./yolo-v5-flask-app
