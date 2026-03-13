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
        
        // 查看随机图片
        document.getElementById('view-btn').addEventListener('click', function() {
            const randomIndex = Math.floor(Math.random() * totalImages) + 1;
            const folder = randomIndex <= 750 ? 'images1' : 'images2';
            const randomImage = 'https://raw.githubusercontent.com/MCQA2580/1/main/' + folder + '/' + randomIndex + '.jpg';
            
            const container = document.getElementById('image-container');
            container.innerHTML = '<img id="image" src="' + randomImage + '" alt="随机图片"><p style="margin-top: 10px; font-size: 0.9rem; color: #666;">图片 ' + randomIndex + ' (共 ' + totalImages + ' 张)</p>';

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
    </script>
</body>
</html>`;

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
        },
      });
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
