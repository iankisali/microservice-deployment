helm install -f values/redis-values.yaml rediscart chart/redis/ -n microservice

helm install -f values/email-service-values.yaml emailservice chart/microservice -n microservice
helm install -f values/cart-service-values.yaml cartservice chart/microservice -n microservice
helm install -f values/currency-service-values.yaml currencyservice chart/microservice -n microservice
helm install -f values/payment-service-values.yaml paymentservice chart/microservice -n microservice
helm install -f values/recommendation-service-values.yaml recommendationservice chart/microservice -n microservice
helm install -f values/productcatalog-service-values.yaml productcatalogservice chart/microservice -n microservice
helm install -f values/shipping-service-values.yaml shippingservice chart/microservice -n microservice
helm install -f values/ad-service-values.yaml adservice chart/microservice -n microservice
helm install -f values/checkout-service-values.yaml checkoutservice chart/microservice -n microservice
helm install -f values/frontend-values.yaml frontendservice chart/microservice -n microservice