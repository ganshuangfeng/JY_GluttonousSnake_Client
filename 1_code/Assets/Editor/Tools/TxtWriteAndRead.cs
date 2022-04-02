using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;  //操作文件夹时需引用该命名空间
using System.Text;

public class TxtWriteAndRead : MonoBehaviour
{
    TextAsset m_Txt;

    void Start()
    {
        // AddTxtTextByFileStream("第一种方法添加text文本");

        // AddTxtTextByFileInfo("第二种方法添加txt文本");

        //重写数据
        // ReWriteMyTxtByFileStreamTxt();

        // ReadTxtFirst();
        //ReadTxtSecond();
        //ReadTxtThird();
        //ReadTxtForth();

        // ReadTxtFifth();
    }

    /// <summary>
    /// 创建txt 方法一
    /// </summary>
    /// <param name="txtText"></param>
    public void AddTxtTextByFileStream(string txtText)
    {
        string path = Application.dataPath + "/Json/MyTxtByFileStream.txt";
        // 文件流创建一个文本文件
        FileStream file = new FileStream(path, FileMode.Create);
        //得到字符串的UTF8 数据流
        byte[] bts = System.Text.Encoding.UTF8.GetBytes(txtText);
        // 文件写入数据流
        file.Write(bts, 0, bts.Length);
        if (file != null)
        {
            //清空缓存
            file.Flush();
            // 关闭流
            file.Close();
            //销毁资源
            file.Dispose();
        }
    }

    /// <summary>
    /// 可以重新写入文件到一个已存在的txt文本中去
    /// </summary>
    void ReWriteMyTxtByFileStreamTxt()
    {
        string path = Application.dataPath + "/Json/MyTxtByFileStream.txt";

        string[] strs = { "123", "321", "234" };

        File.WriteAllLines(path, strs);

        /*
         文本内容为：（逐行显示的）
         123
         321
         234
         原文本内容为：
         第一种方法添加text文本
         */

        //如果想在某一行中添加一行新的，可以将原txt文本读取下来，保存到数组里，
        //然后新建一个数组，载将原数组文本与新加入的行数据同时写入到新数组里
        //然后用新数组数据替换（重写）原来的数据
    }

    /// <summary>
    /// 创建txt 方法二
    /// </summary>
    /// <param name="txtText"></param>
    public void AddTxtTextByFileInfo(string txtText)
    {
       string path = Application.dataPath + "/MyInfo.txt";
        StreamWriter sw;
        FileInfo fi = new FileInfo(path);

        if (!File.Exists(path))
        {
            sw = fi.CreateText();
        }
        else {
            sw = fi.AppendText();   //在原文件后面追加内容      
        }
        sw.WriteLine(txtText);
        sw.Close();
        sw.Dispose();
    }

    /// <summary>
    /// 读取txt文本方法一
    /// 需要将txt文本放到Resources文件夹下读取
    /// </summary>
    void ReadTxtFirst()
    {
        m_Txt = Resources.Load<TextAsset>("readTxt");
        string str = m_Txt.text.ToString();
        print(str);  //txt文本数据读取
    }

    /// <summary>
    /// 读取txt文本方法二
    /// 逐行读取 该方法可以单独获取某一行的数据
    /// </summary>
    void ReadTxtSecond()
    {
        string path = Application.dataPath + "/Json/MyTxtByFileInfo.txt";
        //逐行读取返回的为数组数据
        string[] strs = File.ReadAllLines(path);

        foreach (string item in strs)
        {
            print(item); //第二种方法添加txt文本
                         //第二种方法添加txt文本  
        }
    }

    /// <summary>
    /// 第三种读取方法
    /// 需引用  using System.Text;
    /// </summary>
    void ReadTxtThird()
    {

        string path = Application.dataPath + "/Json/MyTxtByFileInfo.txt";

        string str = File.ReadAllText(path, Encoding.UTF8);

        print(str); //第二种方法添加txt文本
                    //第二种方法添加txt文本
    }

    /// <summary>
    /// 第四种读取方法
    /// </summary>
    void ReadTxtForth()
    {
        string path = Application.dataPath + "/Json/MyTxtByFileInfo.txt";
        //FileStream fsSource = new FileStream(path, FileMode.Open, FileAccess.Read);

        //文件读写流
        StreamReader strr = new StreamReader(path);
        //读取内容
        string str = strr.ReadToEnd();

        print(str);  //第二种方法添加txt文本
                     //第二种方法添加txt文本

    }

    /// <summary>
    /// 第五种读取方法
    /// 文件流方式
    /// </summary>
    public string ReadTxtFifth(string _path) {
        string path = _path;//"/Json/MyTxtByFileInfo.txt";
        FileStream files = new FileStream(path, FileMode.Open, FileAccess.Read);
        byte[] bytes = new byte[files.Length];
        files.Read(bytes, 0, bytes.Length);
        files.Close();
        string str = UTF8Encoding.UTF8.GetString(bytes);
        // print(str);     //第二种方法添加txt文本
                        //第二种方法添加txt文本
        return str;
    }
}