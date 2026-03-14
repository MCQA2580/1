// Cloudflare Workers 部署脚本
// 用于提供静态图片查看器

// 导入 HTML 文件
const htmlContent = `<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>简单图片查看器</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: Arial, sans-serif;
            background-color: #f0f0f0;
            color: #333;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        
        header {
            background-color: #3498db;
            color: white;
            padding: 20px;
            text-align: center;
        }
        
        h1 {
            font-size: 2rem;
            margin-bottom: 10px;
        }
        
        main {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .container {
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            padding: 20px;
            max-width: 800px;
            width: 100%;
            text-align: center;
        }
        
        .image-box {
            margin: 20px 0;
            min-height: 400px;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 2px dashed #ccc;
            border-radius: 5px;
            background-color: #f9f9f9;
        }
        
        #image {
            max-width: 100%;
            max-height: 500px;
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .info {
            margin: 20px 0;
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 5px;
            font-size: 0.9rem;
            color: #666;
        }
        
        .buttons {
            margin: 20px 0;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            justify-content: center;
        }
        
        button {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            font-size: 1rem;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        #view-btn {
            background-color: #3498db;
            color: white;
        }
        
        #view-btn:hover {
            background-color: #2980b9;
            transform: translateY(-2px);
        }
        
        #folder-btn {
            background-color: #2ecc71;
            color: white;
        }
        
        #folder-btn:hover {
            background-color: #27ae60;
            transform: translateY(-2px);
        }
        
        footer {
            background-color: #333;
            color: white;
            text-align: center;
            padding: 15px;
            margin-top: auto;
        }
        
        a {
            color: #3498db;
            text-decoration: none;
            font-weight: bold;
        }
        
        a:hover {
            text-decoration: underline;
        }
        
        /* 加载动画 */
        .loading {
            display: inline-block;
            width: 40px;
            height: 40px;
            border: 3px solid rgba(52, 152, 219, 0.3);
            border-radius: 50%;
            border-top-color: #3498db;
            animation: spin 1s ease-in-out infinite;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        
        /* 图片加载提示 */
        .image-loading {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 1rem;
            padding: 2rem;
        }
        
        .image-loading p {
            color: #3498db;
            font-weight: 600;
        }
        
        /* 成功动画 */
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .fade-in {
            animation: fadeIn 0.5s ease-out;
        }
    </style>
</head>
<body>
    <header>
        <h1>简单图片查看器</h1>
        <p>查看下载的图片</p>
    </header>
    
    <main>
        <div class="container">
            <div class="info">
                <h3>📁 图片信息</h3>
                <p>• 部署方式: Cloudflare Workers</p>
                <p>• 功能: 查看和管理下载的图片</p>
                <p>• 图片数量: 1499 张（images1: 750 张, images2: 749 张）</p>
            </div>
            
            <div class="image-box">
                <div id="image-container">
                    <p>点击下方按钮查看随机图片</p>
                    <small>所有图片均以数字格式命名</small>
                </div>
            </div>
            
            <div class="buttons">
                <button id="view-btn">👁️ 查看随机图片</button>
                <button id="folder-btn">📂 打开图片文件夹</button>
            </div>
        </div>
    </main>
    
    <footer>
        <p>© 2026 简单图片查看器 | <a href="#" id="source-link">查看原始图片</a></p>
    </footer>
    
    <script>
        // 当前图片总数（包括后面新加的）
        const totalImages = 1499; // 初始图片数，后续可手动更新
        // 图片缓存
        const imageCache = new Map();
        // 预加载的图片
        let preloadedImage = null;
        // 加载超时时间
        const LOAD_TIMEOUT = 10000;
        
        // 初始化缓存
        function initCache() {
            try {
                const cached = localStorage.getItem('imageCache');
                if (cached) {
                    const parsed = JSON.parse(cached);
                    parsed.forEach((url, index) => {
                        imageCache.set(index, url);
                    });
                }
            } catch (e) {
                console.log('缓存初始化失败:', e);
            }
        }
        
        // 保存缓存
        function saveCache() {
            try {
                const cacheArray = Array.from(imageCache.entries());
                localStorage.setItem('imageCache', JSON.stringify(cacheArray));
            } catch (e) {
                console.log('缓存保存失败:', e);
            }
        }
        
        // 获取随机图片索引
        function getRandomImageIndex() {
            return Math.floor(Math.random() * totalImages) + 1;
        }
        
        // 预加载图片
        function preloadImage() {
            const randomIndex = getRandomImageIndex();
            const folder = randomIndex <= 750 ? 'images1' : 'images2';
            const imageUrl = 'https://raw.githubusercontent.com/MCQA2580/1/main/' + folder + '/' + randomIndex + '.jpg';
            
            const img = new Image();
            img.src = imageUrl;
            img.onload = function() {
                preloadedImage = { index: randomIndex, url: imageUrl };
            };
        }
        
        // 查看随机图片
        document.getElementById('view-btn').addEventListener('click', function() {
            let randomIndex, imageUrl;
            
            // 使用预加载的图片或获取新图片
            if (preloadedImage) {
                randomIndex = preloadedImage.index;
                imageUrl = preloadedImage.url;
                preloadedImage = null;
                // 立即预加载下一张
                preloadImage();
            } else {
                randomIndex = getRandomImageIndex();
                const folder = randomIndex <= 750 ? 'images1' : 'images2';
                imageUrl = 'https://raw.githubusercontent.com/MCQA2580/1/main/' + folder + '/' + randomIndex + '.jpg';
                // 预加载下一张
                preloadImage();
            }
            
            // 显示加载状态
            const container = document.getElementById('image-container');
            container.innerHTML = `
                <div class="image-loading">
                    <div class="loading"></div>
                    <p>图片加载中...</p>
                </div>
            `;
            
            // 检查缓存
            if (imageCache.has(randomIndex)) {
                imageUrl = imageCache.get(randomIndex);
            }
            
            // 创建图片元素
            const img = new Image();
            img.id = 'image';
            img.src = imageUrl;
            img.alt = '随机图片';
            
            // 设置加载超时
            const timeoutId = setTimeout(() => {
                if (!img.complete) {
                    container.innerHTML = `
                        <div class="fade-in">
                            <p style="color: #e74c3c; font-weight: 600;">⏰ 图片加载超时</p>
                            <p style="color: #666; margin-top: 0.5rem;">网络可能较慢，请稍后重试</p>
                        </div>
                    `;
                    // 预加载下一张
                    preloadImage();
                }
            }, LOAD_TIMEOUT);
            
            img.onload = function() {
                clearTimeout(timeoutId);
                // 图片加载完成
                imageCache.set(randomIndex, imageUrl);
                saveCache();
                
                container.innerHTML = `
                    <div class="fade-in">
                        <img id="image" src="${imageUrl}" alt="随机图片">
                        <p style="margin-top: 10px; font-size: 0.9rem; color: #666;">
                            图片 ${randomIndex} (共 ${totalImages} 张)
                        </p>
                    </div>
                `;
            };
            
            img.onerror = function() {
                clearTimeout(timeoutId);
                // 图片加载失败
                container.innerHTML = `
                    <div class="fade-in">
                        <p style="color: #e74c3c; font-weight: 600;">😞 图片加载失败</p>
                        <p style="color: #666; margin-top: 0.5rem;">请点击按钮重试</p>
                    </div>
                `;
                // 预加载下一张
                preloadImage();
            };
        });
        
        // 打开原始存储
        document.getElementById('folder-btn').addEventListener('click', function() {
            // 打开GitHub仓库中的图片文件夹
            window.open('https://github.com/MCQA2580/1/tree/main', '_blank');
        });
        
        // 底部链接
        document.getElementById('source-link').addEventListener('click', function(e) {
            e.preventDefault();
            window.open('https://github.com/MCQA2580/1', '_blank');
        });
        
        // 初始化
        initCache();
        // 预加载第一张图片
        preloadImage();
    </script>
</body>
</html>`;

// 图片缓存
const imageCache = new Map();

// 处理请求
export default {
  async fetch(request) {
    const url = new URL(request.url);
    const path = url.pathname;
    
    // 处理根路径请求
    if (path === '/' || path === '/index.html') {
      return new Response(htmlContent, {
        headers: {
          'Content-Type': 'text/html; charset=UTF-8',
          'Cache-Control': 'max-age=3600',
          'Content-Encoding': 'gzip',
        },
      });
    }
    
    // 处理图片请求
    if (path.startsWith('/images')) {
      try {
        const imagePath = path.substring(1); // 移除开头的斜杠
        const imageUrl = `https://raw.githubusercontent.com/MCQA2580/1/main/${imagePath}`;
        
        // 检查缓存
        if (imageCache.has(imagePath)) {
          const cachedResponse = imageCache.get(imagePath);
          return new Response(cachedResponse.body, {
            headers: {
              'Content-Type': 'image/jpeg',
              'Cache-Control': 'max-age=86400',
              'X-Cache': 'HIT',
            },
          });
        }
        
        // 从GitHub获取图片
        const response = await fetch(imageUrl);
        
        if (response.ok) {
          // 缓存图片
          const body = await response.clone().arrayBuffer();
          imageCache.set(imagePath, {
            body: body,
            headers: response.headers,
          });
          
          // 返回响应
          return new Response(body, {
            headers: {
              'Content-Type': 'image/jpeg',
              'Cache-Control': 'max-age=86400',
              'X-Cache': 'MISS',
            },
          });
        } else {
          return new Response('Image not found', {
            status: 404,
            headers: {
              'Content-Type': 'text/plain',
            },
          });
        }
      } catch (error) {
        return new Response('Error fetching image', {
          status: 500,
          headers: {
            'Content-Type': 'text/plain',
          },
        });
      }
    }
    
    // 处理其他路径
    return new Response('Not found', {
      status: 404,
      headers: {
        'Content-Type': 'text/plain',
      },
    });
  }
};
