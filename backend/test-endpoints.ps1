# Test Registration
$registerBody = @{
    firstName = "TestUser"
    lastName = "Atlas"
    email = "testatlasuser@example.com"
    password = "Password123!"
    phone = "9876543210"
    role = "customer"
} | ConvertTo-Json

Write-Host "Testing Registration..." -ForegroundColor Cyan
try {
    $regResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/auth/register" -Method POST -Body $registerBody -ContentType "application/json"
    Write-Host "✅ Registration successful!" -ForegroundColor Green
    Write-Host "User ID: $($regResponse.user._id)" -ForegroundColor Yellow
    $token = $regResponse.tokens.accessToken
    Write-Host "Token obtained: $($token.Substring(0,20))..." -ForegroundColor Yellow
} catch {
    Write-Host "❌ Registration failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Login
Write-Host "`nTesting Login..." -ForegroundColor Cyan
$loginBody = @{
    email = "testatlasuser@example.com"
    password = "Password123!"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    Write-Host "✅ Login successful!" -ForegroundColor Green
    $token = $loginResponse.tokens.accessToken
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Products List
Write-Host "`nTesting Products List..." -ForegroundColor Cyan
try {
    $products = Invoke-RestMethod -Uri "http://localhost:5000/api/products" -Method GET
    Write-Host "✅ Products endpoint working!" -ForegroundColor Green
    Write-Host "Total products: $($products.total)" -ForegroundColor Yellow
} catch {
    Write-Host "❌ Products failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Categories
Write-Host "`nTesting Categories..." -ForegroundColor Cyan
try {
    $categories = Invoke-RestMethod -Uri "http://localhost:5000/api/categories" -Method GET
    Write-Host "✅ Categories endpoint working!" -ForegroundColor Green
    Write-Host "Total categories: $($categories.categories.Count)" -ForegroundColor Yellow
} catch {
    Write-Host "❌ Categories failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Cart (with auth)
if ($token) {
    Write-Host "`nTesting Cart (authenticated)..." -ForegroundColor Cyan
    try {
        $headers = @{
            "Authorization" = "Bearer $token"
        }
        $cart = Invoke-RestMethod -Uri "http://localhost:5000/api/cart" -Method GET -Headers $headers
        Write-Host "✅ Cart endpoint working!" -ForegroundColor Green
        Write-Host "Cart items: $($cart.cart.items.Count)" -ForegroundColor Yellow
    } catch {
        Write-Host "❌ Cart failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Test Wishlist
    Write-Host "`nTesting Wishlist (authenticated)..." -ForegroundColor Cyan
    try {
        $wishlist = Invoke-RestMethod -Uri "http://localhost:5000/api/wishlist" -Method GET -Headers $headers
        Write-Host "✅ Wishlist endpoint working!" -ForegroundColor Green
        Write-Host "Wishlist items: $($wishlist.wishlist.items.Count)" -ForegroundColor Yellow
    } catch {
        Write-Host "❌ Wishlist failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n╔════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  ✅ API Testing Complete!         ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════╝" -ForegroundColor Green
