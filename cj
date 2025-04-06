<!DOCTYPE html>
<html>
<head>
    <title>抽奖系统</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 20px auto;
            padding: 20px;
        }
        .section {
            margin-bottom: 30px;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        input[type="file"] {
            margin: 10px 0;
        }
        .award-control {
            margin: 10px 0;
        }
        .award-control label {
            display: inline-block;
            width: 120px;
        }
        button {
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin: 5px;
        }
        button:hover {
            background-color: #45a049;
        }
        #result {
            margin-top: 20px;
            padding: 15px;
            background-color: #f9f9f9;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #4CAF50;
            color: white;
        }
    </style>
</head>
<body>
    <!-- 在文件输入框下方添加编码选择 -->
<div class="section">
    <h2>1. 导入参与名单</h2>
    <input type="file" id="fileInput" accept=".csv">
    <div style="margin:10px 0;">
        <label>文件编码：</label>
        <select id="encoding">
            <option value="utf-8">UTF-8</option>
            <option value="gbk">GBK</option>
            <option value="big5">Big5</option>
        </select>
    </div>
    <div id="participantCount"></div>
</div>

<script>
// 修改文件读取部分
document.getElementById('fileInput').addEventListener('change', function(e) {
    const file = e.target.files[0];
    const reader = new FileReader();
    const encoding = document.getElementById('encoding").value;
    
    reader.onload = function(e) {
        // 使用TextDecoder处理编码
        const decoder = new TextDecoder(encoding);
        const data = decoder.decode(e.target.result);
        participants = data.split(/\r?\n/)  // 兼容不同换行符
            .map(item => item.trim())
            .filter(item => item);
        document.getElementById('participantCount').innerHTML = `已导入 ${participants.length} 位参与者`;
    };
    
    // 改为读取ArrayBuffer
    reader.readAsArrayBuffer(file);
});
</script>

    <div class="section">
        <h2>2. 设置奖项人数</h2>
        <div class="award-control">
            <label>特等奖人数：</label>
            <input type="number" id="special" min="0" value="1">
        </div>
        <div class="award-control">
            <label>一等奖人数：</label>
            <input type="number" id="first" min="0" value="3">
        </div>
        <div class="award-control">
            <label>二等奖人数：</label>
            <input type="number" id="second" min="0" value="5">
        </div>
        <div class="award-control">
            <label>三等奖人数：</label>
            <input type="number" id="third" min="0" value="10">
        </div>
    </div>

    <div class="section">
        <h2>3. 开始抽奖</h2>
        <button onclick="draw()">开始抽奖</button>
        <button onclick="reset()">重置</button>
        <div id="result"></div>
    </div>

    <script>
        let participants = [];
        let result = {
            special: [],
            first: [],
            second: [],
            third: []
        };

        // 文件读取
        document.getElementById('fileInput').addEventListener('change', function(e) {
            const file = e.target.files[0];
            const reader = new FileReader();
            
            reader.onload = function(e) {
                participants = e.target.result.split('\n').map(item => item.trim()).filter(Boolean);
                document.getElementById('participantCount').innerHTML = `已导入 ${participants.length} 位参与者`;
            };
            
            reader.readAsText(file);
        });

        // 抽奖函数
        function draw() {
            if (participants.length === 0) {
                alert('请先导入参与者名单');
                return;
            }

            const required = getRequiredNumbers();
            if (required.total > participants.length) {
                alert('剩余人数不足');
                return;
            }

            // 抽奖逻辑
            result.special = drawNames(required.special);
            result.first = drawNames(required.first);
            result.second = drawNames(required.second);
            result.third = drawNames(required.third);

            showResults();
        }

        function drawNames(count) {
            const winners = [];
            for (let i = 0; i < count; i++) {
                if (participants.length === 0) break;
                const index = Math.floor(Math.random() * participants.length);
                winners.push(participants.splice(index, 1)[0]);
            }
            return winners;
        }

        function getRequiredNumbers() {
            return {
                special: parseInt(document.getElementById('special').value) || 0,
                first: parseInt(document.getElementById('first').value) || 0,
                second: parseInt(document.getElementById('second').value) || 0,
                third: parseInt(document.getElementById('third').value) || 0,
                get total() {
                    return this.special + this.first + this.second + this.third;
                }
            };
        }

        function showResults() {
            let html = '<h3>抽奖结果</h3>';
            
            const awards = [
                {name: 'special', title: '特等奖'},
                {name: 'first', title: '一等奖'},
                {name: 'second', title: '二等奖'},
                {name: 'third', title: '三等奖'}
            ];

            awards.forEach(award => {
                if (result[award.name].length > 0) {
                    html += `<table>
                                <tr><th>${award.title}（${result[award.name].length}人）</th></tr>
                                ${result[award.name].map(name => `<tr><td>${name}</td></tr>`).join('')}
                            </table>`;
                }
            });

            document.getElementById('result').innerHTML = html;
        }

        function reset() {
            participants = [];
            result = {
                special: [],
                first: [],
                second: [],
                third: []
            };
            document.getElementById('fileInput').value = '';
            document.getElementById('participantCount').innerHTML = '';
            document.getElementById('result').innerHTML = '';
        }
    </script>
</body>
</html>
