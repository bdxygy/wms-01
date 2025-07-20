I/flutter (24454): 🔄 AuthProvider state changed to: AuthState.loading
I/flutter (24454): **_ Request _**
I/flutter (24454): uri: http://192.168.0.102:3000/api/v1/auth/login
I/flutter (24454): method: POST
I/flutter (24454): responseType: ResponseType.json
I/flutter (24454): followRedirects: true
I/flutter (24454): persistentConnection: true
I/flutter (24454): connectTimeout: 0:00:30.000000
I/flutter (24454): sendTimeout: 0:00:30.000000
I/flutter (24454): receiveTimeout: 0:00:30.000000
I/flutter (24454): receiveDataWhenStatusError: true
I/flutter (24454): extra: {}
I/flutter (24454): headers:
I/flutter (24454): Content-Type: application/json
I/flutter (24454): Accept: application/json
I/flutter (24454): data:
I/flutter (24454): {username: devel, password: devel@123}
I/flutter (24454):
I/flutter (24454): **_ Response _**
I/flutter (24454): uri: http://192.168.0.102:3000/api/v1/auth/login
I/flutter (24454): Response Text:
I/flutter (24454): {"success":true,"data":{"user":{"id":"4337fda2-1d4a-410a-89d2-2431d93b51ba","name":"devel","username":"devel","role":"OWNER","ownerId":null,"isActive":true,"createdAt":"2025-07-19T00:12:09.000Z","updatedAt":"2025-07-19T00:12:09.000Z"},"tokens":{"accessToken":"eyJhbGciOiJIUzI1NiJ9.eyJ1c2VySWQiOiI0MzM3ZmRhMi0xZDRhLTQxMGEtODlkMi0yNDMxZDkzYjUxYmEiLCJyb2xlIjoiT1dORVIiLCJpYXQiOjE3NTI5ODM3MTUsImV4cCI6MTc1MzA3MDExNX0.uIWRujeY9MB7fw3mBhYQXfxb1eftXi3gLQMEbhGPz6k"}},"timestamp":"2025-07-20T03:55:15.423Z"}
I/flutter (24454):
I/flutter (24454): 🔄 AuthProvider state changed to: AuthState.error
I/flutter (24454): ❌ AuthProvider error: Login failed: type 'Null' is not a subtype of type 'String' in type cast
