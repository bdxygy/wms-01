I/flutter (24454): 🔄 AuthProvider state changed to: AuthState.loading
I/flutter (24454): *** Request ***
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
I/flutter (24454):  Content-Type: application/json
I/flutter (24454):  Accept: application/json
I/flutter (24454): data:
I/flutter (24454): {username: devel, password: devel@123}
I/flutter (24454): 
I/flutter (24454): *** Response ***
I/flutter (24454): uri: http://192.168.0.102:3000/api/v1/auth/login
I/flutter (24454): Response Text:
I/flutter (24454): {"success":true,"data":{"user":{"id":"4337fda2-1d4a-410a-89d2-2431d93b51ba","name":"devel","username":"devel","role":"OWNER","ownerId":null,"isActive":true,"createdAt":"2025-07-19T00:12:09.000Z","updatedAt":"2025-07-19T00:12:09.000Z"},"tokens":{"accessToken":"eyJhbGciOiJIUzI1NiJ9.eyJ1c2VySWQiOiI0MzM3ZmRhMi0xZDRhLTQxMGEtODlkMi0yNDMxZDkzYjUxYmEiLCJyb2xlIjoiT1dORVIiLCJpYXQiOjE3NTI5ODQ5NDAsImV4cCI6MTc1MzA3MTM0MH0.QVfy2RmwgQB-kcno29Y0QuTF3FWt2LjJdwNA3aPnClA"}},"timestamp":"2025-07-20T04:15:40.578Z"}
I/flutter (24454): 
I/flutter (24454): ⚠️ Slow API request: /auth/login took 4944ms
I/flutter (24454): 🔐 User devel logged in successfully
I/flutter (24454): 🔄 AuthProvider state changed to: AuthState.authenticated
I/flutter (24454): 👑 OWNER devel logged in
[GoRouter] getting location for name: "dashboard"
[GoRouter] going to /dashboard
W/WindowOnBackDispatcher(24454): OnBackInvokedCallback is not enabled for the application.
W/WindowOnBackDispatcher(24454): Set 'android:enableOnBackInvokedCallback="true"' in the application manifest.
I/ImeTracker(24454): com.wms.wms_mobile:dc509344: onRequestHide at ORIGIN_CLIENT_HIDE_SOFT_INPUT reason HIDE_SOFT_INPUT