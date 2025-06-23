# Final Project

## Steps

cd object-detection-react-app && docker build . -t ashutoxh/object-detection-react-app
cd object-detection-react-app && docker push ashutoxh/object-detection-react-app
cd yolo-v5-flask-app && docker build . -t ashutoxh/yolo-v5-flask-app

cd yolo-v5-flask-app && docker push ashutoxh/yolo-v5-flask-app
cd depth-anything-flask-app && docker build . -t ashutoxh/depth-anything-flask-app
cd depth-anything-flask-app && docker push ashutoxh/depth-anything-flask-app


