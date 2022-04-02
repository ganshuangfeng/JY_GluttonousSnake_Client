using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;

using System.Runtime.InteropServices;
using System.Reflection;
using System.Text;
using System.Security;




public class AStar : MonoBehaviour
{
	private Int64 astar_obj;
	private PointTem[] path = new PointTem[3000];
	private SizeTem _gridSize;

	private const int count = 3000;
	private static int PointTemSize = Marshal.SizeOf(typeof(PointTem));
	private static int intSize = Marshal.SizeOf(typeof(int));

	IntPtr getPathByNo_ptr = Marshal.AllocHGlobal(PointTemSize * count);
	PointTem[] getPathByNo_path = new PointTem[count];

	IntPtr getPathNoByNo_ptr = Marshal.AllocHGlobal(intSize * count);
	int[] getPathNoByNo_path = new int[count];

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
	/// 创建对象
	public void Create(PointTem origin , SizeTem gridSize, int x_grid_num , int y_grid_num )
	{
		_gridSize.width = gridSize.width ;
		_gridSize.height = gridSize.height ;
		astar_obj = LuaDLL.PF_Create( origin ,  gridSize,  x_grid_num , y_grid_num );
	}

	/// 删除对象
	public void Destroy()
	{
		if (astar_obj == 0) return;
		LuaDLL.PF_Destroy( astar_obj);
		astar_obj = 0;
		
		//GameObject.Destroy(this);
	}
	/// 设置格子大小
	public void setGridSize(float w, float h)
	{
		if (astar_obj == 0) return;
		LuaDLL.PF_setGridSize(astar_obj , w , h);
		
	}
	// 设置地图尺寸 , 参数是格子个个数
	public void setMapSize(int w, int h)
	{
		if (astar_obj == 0) return;
		LuaDLL.PF_setMapSize(astar_obj , w , h);
		
	}
	// 获得 在 x 上的编号 by 一维编号
	public int getCoordXByNo(int no)
	{
		if (astar_obj == 0) return -1;
	    return LuaDLL.PF_getCoordXByNo(astar_obj , no);
	}

	// 获得 在 y 上的编号 by 一维编号
	public int getCoordYByNo(int no)
	{
		if (astar_obj == 0) return -1;
	    return LuaDLL.PF_getCoordYByNo(astar_obj , no);
	}

	// 获得 一维编号 by x,y 上的编号
	public int getNoByCoord(int x, int y)
	{
		if (astar_obj == 0) return -1;
	    return LuaDLL.PF_getNoByCoord(astar_obj , x , y);
	}
	
	// 获得中心点，通过一维no表
	public PointTem getCenterPointByNo(int no )
	{
		if (astar_obj == 0) return new PointTem();
		PointTem result = new PointTem() ;
	    LuaDLL.PF_getCenterPointByNo(astar_obj , no ,ref result);
	    return result;
	}

	// 获得中心点，通过二维no表
	public PointTem getCenterPointByXY(int x, int y )
	{
		//if (astar_obj == 0) return null;
	    return LuaDLL.PF_getCenterPointByXY(astar_obj , x, y);
	}

	/// 设置一个no 的格子，是否安全，可以通过
	public bool setNodeInf( int no, bool isSafe )
	{
		//if (astar_obj == 0) return false;
	    return LuaDLL.PF_setNodeInf(astar_obj , no , isSafe);
	}
	
	/// 设置一个no 的格子，是否安全，可以通过
	public bool checkIsSafeByNo( int no )
	{
		//if (astar_obj == 0) return false;
	    return LuaDLL.PF_checkIsSafeByNo(astar_obj , no );
	}

	/// 获得路径中心点 , 参数是no
	public AStarPath getPathByNo( int s, int e )
	{
		//Debug.Log("xx----------getPathByNo init:" + s + "," + e );
		/// 调用C++ 计算
		int length = LuaDLL.PF_getPathByNo( astar_obj , s, e , getPathByNo_ptr );
		//Debug.Log("xx----------getPathByNo:length:" + length);

		for(int i = 0;i<length ; i++ )
		{
			IntPtr ttr = (IntPtr)((UInt32)getPathByNo_ptr + i*PointTemSize);
			getPathByNo_path[i] = (PointTem)Marshal.PtrToStructure(ttr , typeof(PointTem));
		}

		AStarPath pathStruct = new AStarPath();
		pathStruct.pathXY = new PointTem[length];
		pathStruct.pathNo = new int[length];
		pathStruct.len = length;

		for(int i = 0;i < length ;i++)
		{
			pathStruct.pathXY[i].x = getPathByNo_path[i].x;
			pathStruct.pathXY[i].y = getPathByNo_path[i].y;

			/// 这个no赋值好像有问题
			int no = getNoByCoord( (int)Math.Floor(getPathByNo_path[i].x / _gridSize.width)+1 , (int)Math.Floor(getPathByNo_path[i].y / _gridSize.height)+1  );
			pathStruct.pathNo[i] = no;
		}

		return pathStruct;
	}

	public Int64 add(Int64 a , Int64 b)
	{
        Int64 ii = (a&b)<<1;
        Int64 jj = a^b;
		if(ii==0)
		{
			return jj;
		}
		else
        {
			return add(jj , ii);
        }
		
	}

	/// 获得路径no , 参数是no
	public AStarPath getPathNoByNo( int s, int e )
	{
		//Debug.Log("xxxx------------getPathNoByNo 1");
		/// 调用C++ 计算
		int length = LuaDLL.PF_getPathNoByNo( astar_obj , s, e , getPathNoByNo_ptr );
		//Debug.Log("xxxx------------getPathNoByNo 2");
		for(int i = 0;i<length ; i++ )
		{
//Debug.Log("xxxx------------getPathNoByNo 2 111");
			IntPtr ttr = (IntPtr)( add((Int64)getPathNoByNo_ptr , (Int64)i*intSize) );  //(UInt64)getPathNoByNo_ptr + i*intSize);
                            //IntPtr ttr = (IntPtr)( (UInt64)getPathNoByNo_ptr + i*intSize);
//Debug.Log("xxxx------------getPathNoByNo 2 222" );
//Debug.Log(getPathNoByNo_ptr );
//Debug.Log(ttr );
//Debug.Log( i );
//Debug.Log( intSize );
			getPathNoByNo_path[i] = (int)Marshal.PtrToStructure(ttr , typeof(int));
//Debug.Log("xxxx------------getPathNoByNo 2 333");
		}
//Debug.Log("xxxx------------getPathNoByNo 3");

		AStarPath pathStruct = new AStarPath();
		pathStruct.pathXY = new PointTem[length];
		pathStruct.pathNo = new int[length];
		pathStruct.len = length;
//Debug.Log("xxxx------------getPathNoByNo 4");
		for(int i = 0;i < length ;i++)
		{
			pathStruct.pathNo[i] = getPathNoByNo_path[i];

			PointTem centerPos = getCenterPointByNo( getPathNoByNo_path[i] );

			pathStruct.pathXY[i].x = centerPos.x;
			pathStruct.pathXY[i].y = centerPos.y;

		}
//Debug.Log("xxxx------------getPathNoByNo 5");
		return pathStruct;
	}

	

}
