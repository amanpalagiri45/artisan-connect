from fastapi import APIRouter, HTTPException, Request, status
from fastapi.responses import RedirectResponse
from authlib.integrations.starlette_client import OAuth, OAuthError
from app.config import settings

router = APIRouter(prefix="/auth/google", tags=["Google Authentication"])
oauth = OAuth()

if settings.GOOGLE_CLIENT_ID and settings.GOOGLE_CLIENT_SECRET:
    oauth.register(
        name="google",
        client_id=settings.GOOGLE_CLIENT_ID,
        client_secret=settings.GOOGLE_CLIENT_SECRET,
        server_metadata_url="https://accounts.google.com/.well-known/openid-configuration",
        client_kwargs={"scope": "openid email profile"},
    )


@router.get("/login")
async def google_login(request: Request):
    if not settings.GOOGLE_CLIENT_ID or not settings.GOOGLE_CLIENT_SECRET:
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Google OAuth is not configured")
    redirect_uri = settings.GOOGLE_REDIRECT_URI
    return await oauth.google.authorize_redirect(request, redirect_uri)


@router.get("/callback")
async def google_callback(request: Request):
    try:
        token = await oauth.google.authorize_access_token(request)
        userinfo = token.get("userinfo") or await oauth.google.userinfo(token=token)
    except (OAuthError, ValueError) as exc:
        request.session["oauth_error"] = "Google sign-in could not be completed. Please try again."
        return RedirectResponse(f"{settings.FRONTEND_URL}/?auth_error={str(exc)[:120]}", status_code=status.HTTP_302_FOUND)

    request.session["user"] = {
        "sub": userinfo.get("sub"),
        "email": userinfo.get("email"),
        "full_name": userinfo.get("name") or userinfo.get("email"),
        "picture": userinfo.get("picture"),
    }
    request.session.pop("oauth_error", None)
    return RedirectResponse(settings.FRONTEND_URL, status_code=status.HTTP_302_FOUND)


@router.get("/session")
async def google_session(request: Request):
    user = request.session.get("user")
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not signed in")
    return user


@router.post("/logout")
async def google_logout(request: Request):
    request.session.clear()
    return {"message": "Signed out"}