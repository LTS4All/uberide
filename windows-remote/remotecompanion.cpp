#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <wincodec.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#include <objbase.h>
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <string>
#include <vector>
#include <sstream>
#include <random>
#include <thread>
#include <atomic>
#include <algorithm>
#pragma comment(lib, "ws2_32.lib")
#pragma comment(lib, "user32.lib")
#pragma comment(lib, "gdi32.lib")
#pragma comment(lib, "ole32.lib")
#pragma comment(lib, "windowscodecs.lib")

static std::string token;
static std::atomic<bool> running(true);
static int port = 8765;
static const char *page = R"HTML(<!doctype html><meta name=viewport content="width=device-width,initial-scale=1"><title>Uberide Remote</title><style>body{margin:0;background:#111;color:#eee;font:16px Arial;text-align:center}#screen{max-width:100%;height:auto;touch-action:none}button,input{font-size:18px;padding:10px;margin:4px}#bar{position:fixed;bottom:0;left:0;right:0;background:#222;padding:5px}</style><img id=screen src="/stream?TOKEN"><div id=bar><button onclick="send('click',0)">Click</button><button onclick="send('right',0)">Right click</button><button onclick="send('key',13)">Enter</button><input id=k placeholder="Type text" autocapitalize=off><button onclick="typeText()">Send</button><button onclick="send('stop',0)">STOP</button></div><script>
const q=new URLSearchParams(location.search),t=q.get('t')||'';let im=document.getElementById('screen');function api(s){return fetch('/input?t='+encodeURIComponent(t),{method:'POST',headers:{'Content-Type':'application/json'},body:s})}function send(a,k){api(JSON.stringify({a:a,k:k,x:0,y:0}))}function typeText(){api(JSON.stringify({a:'text',v:document.getElementById('k').value}))}function pos(e){let r=im.getBoundingClientRect();return{x:Math.round((e.clientX-r.left)*(im.naturalWidth||r.width)/r.width),y:Math.round((e.clientY-r.top)*(im.naturalHeight||r.height)/r.height)}}im.addEventListener('click',e=>{let p=pos(e);api(JSON.stringify({a:'click',x:p.x,y:p.y}))});im.addEventListener('contextmenu',e=>{e.preventDefault();let p=pos(e);api(JSON.stringify({a:'right',x:p.x,y:p.y}));return false});
</script>)HTML";

static std::string randomToken(){ static const char h[]="0123456789abcdef"; std::random_device d; std::mt19937 g(d()); std::string s; for(int i=0;i<32;i++) s+=h[g()%16]; return s; }
static bool authorized(const std::string& u){return u.find(std::string("t=")+token)!=std::string::npos || u.find(std::string("?")+token)!=std::string::npos;}
static void sendAll(SOCKET s,const char*b,int n){while(n>0){int z=send(s,b,n,0);if(z<=0)return;b+=z;n-=z;}}
static void reply(SOCKET s,const std::string& body,const char*type="text/html"){std::string h=std::string("HTTP/1.1 200 OK\r\nContent-Type: ")+type+"\r\nContent-Length: "+std::to_string(body.size())+"\r\nCache-Control: no-store\r\nConnection: close\r\n\r\n";sendAll(s,h.c_str(),(int)h.size());sendAll(s,body.data(),(int)body.size());}
static std::vector<unsigned char> pngCapture(){
 IStream*out=nullptr; HDC dc=GetDC(nullptr); int w=GetSystemMetrics(SM_CXSCREEN),h=GetSystemMetrics(SM_CYSCREEN); HDC mem=CreateCompatibleDC(dc); HBITMAP bm=CreateCompatibleBitmap(dc,w,h); HGDIOBJ old=SelectObject(mem,bm); BitBlt(mem,0,0,w,h,dc,0,0,SRCCOPY|CAPTUREBLT); SelectObject(mem,old); IWICImagingFactory*f=nullptr; IWICBitmap*wb=nullptr; IWICBitmapEncoder*enc=nullptr; IWICBitmapFrameEncode*fr=nullptr; IPropertyBag2*bag=nullptr; std::vector<unsigned char> data;
 if(SUCCEEDED(CoCreateInstance(CLSID_WICImagingFactory,nullptr,CLSCTX_INPROC_SERVER,IID_PPV_ARGS(&f)))&&SUCCEEDED(f->CreateBitmapFromHBITMAP(bm,nullptr,WICBitmapUsePremultipliedAlpha,&wb))&&SUCCEEDED(CreateStreamOnHGlobal(nullptr,TRUE,&out))&&SUCCEEDED(f->CreateEncoder(GUID_ContainerFormatPng,nullptr,&enc))&&SUCCEEDED(enc->Initialize(out,WICBitmapEncoderNoCache))&&SUCCEEDED(enc->CreateNewFrame(&fr,&bag))&&SUCCEEDED(fr->Initialize(bag))&&SUCCEEDED(fr->SetSize(w,h))&&SUCCEEDED(fr->SetPixelFormat(nullptr))&&SUCCEEDED(fr->WriteSource(wb,nullptr))&&SUCCEEDED(fr->Commit())&&SUCCEEDED(enc->Commit())){HGLOBAL hg=nullptr;GetHGlobalFromStream(out,&hg);SIZE_T n=GlobalSize(hg);void*p=GlobalLock(hg);if(p)data.assign((unsigned char*)p,(unsigned char*)p+n);GlobalUnlock(hg);}
 if(bag)bag->Release();if(fr)fr->Release();if(enc)enc->Release();if(wb)wb->Release();if(out)out->Release();if(f)f->Release();DeleteObject(bm);DeleteDC(mem);ReleaseDC(nullptr,dc);return data;
}
static void moveClick(int x,int y,bool right){int w=GetSystemMetrics(SM_CXSCREEN),h=GetSystemMetrics(SM_CYSCREEN);INPUT i{};i.type=INPUT_MOUSE;i.mi.dx=(LONG)((long long)x*65535/(w-1));i.mi.dy=(LONG)((long long)y*65535/(h-1));i.mi.dwFlags=MOUSEEVENTF_ABSOLUTE|MOUSEEVENTF_MOVE;SendInput(1,&i,sizeof(i));i.mi.dwFlags=MOUSEEVENTF_ABSOLUTE|(right?MOUSEEVENTF_RIGHTDOWN:MOUSEEVENTF_LEFTDOWN);SendInput(1,&i,sizeof(i));i.mi.dwFlags=MOUSEEVENTF_ABSOLUTE|(right?MOUSEEVENTF_RIGHTUP:MOUSEEVENTF_LEFTUP);SendInput(1,&i,sizeof(i));}
static void key(int k){INPUT i{};i.type=INPUT_KEYBOARD;i.ki.wVk=(WORD)k;SendInput(1,&i,sizeof(i));i.ki.dwFlags=KEYEVENTF_KEYUP;SendInput(1,&i,sizeof(i));}
static void text(const std::string&v){for(unsigned char c:v){INPUT i{};i.type=INPUT_KEYBOARD;i.ki.dwFlags=KEYEVENTF_UNICODE;i.ki.wScan=c;SendInput(1,&i,sizeof(i));i.ki.dwFlags=KEYEVENTF_UNICODE|KEYEVENTF_KEYUP;SendInput(1,&i,sizeof(i));}}
static void handle(SOCKET s){char b[8192]={};int n=recv(s,b,sizeof(b)-1,0);if(n<=0){closesocket(s);return;}std::string req(b,n),line=req.substr(0,req.find("\r\n"));size_t a=line.find(' '),z=line.find(' ',a+1);std::string method=line.substr(0,a),u=line.substr(a+1,z-a-1);if(method=="GET"&&u.rfind("/stream",0)==0){if(!authorized(u)){reply(s,"unauthorized","text/plain");closesocket(s);return;}std::string h="HTTP/1.1 200 OK\r\nContent-Type: multipart/x-mixed-replace; boundary=frame\r\nCache-Control: no-store\r\nConnection: close\r\n\r\n";sendAll(s,h.c_str(),(int)h.size());while(running){auto p=pngCapture();if(p.empty())break;std::string ph="--frame\r\nContent-Type: image/png\r\nContent-Length: "+std::to_string(p.size())+"\r\n\r\n";sendAll(s,ph.c_str(),(int)ph.size());sendAll(s,(char*)p.data(),(int)p.size());sendAll(s,"\r\n",2);Sleep(100);}closesocket(s);return;}if(method=="GET"&&u.rfind("/",0)==0){std::string x=page;size_t p=x.find("?TOKEN");if(p!=std::string::npos)x.replace(p,6,"?t="+token);reply(s,x.c_str());closesocket(s);return;}if(method=="POST"&&u.rfind("/input",0)==0){if(!authorized(u)){reply(s,"unauthorized","text/plain");closesocket(s);return;}size_t q=req.find("\r\n\r\n");std::string body=q==std::string::npos?"":req.substr(q+4);int x=0,y=0,k=0; if(body.find("\"x\"")!=std::string::npos)sscanf(body.c_str(),"%*[^x]x%*[^0-9]%d%*[^y]y%*[^0-9]%d",&x,&y);if(body.find("\"right\"")!=std::string::npos)moveClick(x,y,true);else if(body.find("\"click\"")!=std::string::npos)moveClick(x,y,false);else if(body.find("\"key\"")!=std::string::npos){sscanf(body.c_str(),"%*[^k]k%*[^0-9]%d",&k);key(k);}else if(body.find("\"text\"")!=std::string::npos){size_t v=body.find("\"v\":\"");if(v!=std::string::npos){v+=5;size_t e=body.find('"',v);text(body.substr(v,e-v));}}else if(body.find("\"stop\"")!=std::string::npos)running=false;reply(s,"ok","text/plain");closesocket(s);return;}reply(s,"not found","text/plain");closesocket(s);}
int main(){SetConsoleTitleA("Uberide Remote Companion - LOCAL CONTROL");token=randomToken();if(const char*p=getenv("UBERIDE_REMOTE_PORT"))port=atoi(p);WSADATA w;WSAStartup(MAKEWORD(2,2),&w);CoInitializeEx(nullptr,COINIT_MULTITHREADED);RegisterHotKey(nullptr,1,MOD_CONTROL|MOD_ALT,VK_PAUSE);std::thread([](){MSG m;while(running&&GetMessage(&m,nullptr,0,0)>0)if(m.message==WM_HOTKEY&&m.wParam==1)running=false;}).detach();SOCKET ls=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);sockaddr_in a{};a.sin_family=AF_INET;a.sin_addr.s_addr=htonl(INADDR_ANY);a.sin_port=htons((u_short)port);if(bind(ls,(sockaddr*)&a,sizeof(a))||listen(ls,4)){printf("Could not bind port %d.\n",port);return 1;}printf("Uberide Remote Companion (Windows 11, LAN only)\nPairing token: %s\nOpen in Surf: http://PC-LAN-IP:%d/?t=%s\nStop: Ctrl+Alt+Pause or close this window. Do not port-forward this service.\n",token.c_str(),port,token.c_str());while(running){SOCKET s=accept(ls,nullptr,nullptr);if(s!=INVALID_SOCKET)std::thread(handle,s).detach();}closesocket(ls);UnregisterHotKey(nullptr,1);CoUninitialize();WSACleanup();return 0;}
