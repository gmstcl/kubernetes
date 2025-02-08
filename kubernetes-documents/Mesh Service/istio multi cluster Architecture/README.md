# istio multi cluster Architecture

## Architecture 
<img src="image.png" alt="architecture.com" width="806" height="733">

### Goal : 
Pod , Object 들은 모두 mTLS 통신을 진행하고, A cluster에서 장애가 발생 시 B Cluster에서 대신 처리를 해야 합니다. 
