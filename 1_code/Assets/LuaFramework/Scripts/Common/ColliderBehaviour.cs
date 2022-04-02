using UnityEngine;
using LuaInterface;

namespace LuaFramework
{
    public class ColliderBehaviour : MonoBehaviour
    {
        public string luaTableName = "";
		public LuaTable luaTable = null;
        public bool collisionStay2D = false;
        public bool collisionStay = false;
        public bool triggerStay2D = false;
        public bool triggerStay = false;
        public bool isDebug = false;

        private void OnCollisionEnter2D(Collision2D coll)
        {
            if (isDebug){
                Debug.Log("OnCollisionEnter2D");
                Debug.Log(coll);
                Debug.Log(luaTable);
            }
            if (luaTable == null) return;
            Util.CallMethod(luaTableName, "OnCollisionEnter2D", luaTable, coll);
        }

        private void OnCollisionExit2D(Collision2D coll)
        {
            if (isDebug){
                Debug.Log("OnCollisionExit2D");
                Debug.Log(coll);
                Debug.Log(luaTable);
            }
            if (luaTable == null) return;
            Util.CallMethod(luaTableName, "OnCollisionExit2D", luaTable, coll);
        }

        private void OnCollisionStay2D(Collision2D coll)
        {
            if (isDebug){
                Debug.Log("OnCollisionStay2D");
                Debug.Log(coll);
                Debug.Log(luaTable);
            }
            if (collisionStay2D == false) return;
            if (luaTable == null) return;
            Util.CallMethod(luaTableName, "OnCollisionStay2D", luaTable, coll);
        }

        private void OnTriggerEnter2D(Collider2D coll)
        {
            if (isDebug){
                Debug.Log("OnTriggerEnter2D");
                Debug.Log(coll);
                Debug.Log(luaTable);
            }
            if (luaTable == null) return;
            Util.CallMethod(luaTableName, "OnTriggerEnter2D", luaTable, coll);
        }

        private void OnTriggerExit2D(Collider2D coll)
        {
            if (isDebug){
                Debug.Log("OnTriggerExit2D");
                Debug.Log(coll);
                Debug.Log(luaTable);
            }
            if (luaTable == null) return;
            Util.CallMethod(luaTableName, "OnTriggerExit2D", luaTable, coll);
        }

        private void OnTriggerStay2D(Collider2D coll)
        {
            if (isDebug){
                Debug.Log("OnTriggerStay2D");
                Debug.Log(coll);
                Debug.Log(luaTable);
            }
            if (triggerStay2D == false) return;
            if (luaTable == null) return;
            Util.CallMethod(luaTableName, "OnTriggerStay2D", luaTable, coll);
        }

        private void OnCollisionEnter(Collision coll)
        {
            if (isDebug){
                Debug.Log("OnCollisionEnter");
                Debug.Log(coll);
                Debug.Log(luaTable);
            }
            if (luaTable == null) return;
            Util.CallMethod(luaTableName, "OnCollisionEnter", luaTable, coll);
            
        }

        private void OnCollisionExit(Collision coll)
        {
            if (isDebug){
                Debug.Log("OnCollisionExit");
                Debug.Log(coll);
                Debug.Log(luaTable);
            }
            if (luaTable == null) return;
            Util.CallMethod(luaTableName, "OnCollisionExit", luaTable, coll);
            
        }

        private void OnCollisionStay(Collision coll)
        {
            if (isDebug){
                Debug.Log("OnCollisionStay");
                Debug.Log(coll);
                Debug.Log(luaTable);
            }
            if (collisionStay == false) return;
            if (luaTable == null) return;
            Util.CallMethod(luaTableName, "OnCollisionStay", luaTable, coll);
            
        }

        public void OnTriggerEnter(Collider coll)
        {
            if (isDebug){
                Debug.Log("OnTriggerEnter");
                Debug.Log(coll);
                Debug.Log(luaTable);
            }
            if (luaTable == null) return;
            Util.CallMethod(luaTableName, "OnTriggerEnter", luaTable, coll);
        }

        public void OnTriggerExit(Collider coll)
        {
            if (isDebug){
                Debug.Log("OnTriggerExit");
                Debug.Log(coll);
                Debug.Log(luaTable);
            }
            if (luaTable == null) return;
            Util.CallMethod(luaTableName, "OnTriggerExit", luaTable, coll);
        }

         public void OnTriggerStay(Collider coll)
        {
            if (isDebug){
                Debug.Log("OnTriggerStay");
                Debug.Log(coll);
                Debug.Log(luaTable);
            }
            if (triggerStay == false) return;
            if (luaTable == null) return;
            Util.CallMethod(luaTableName, "OnTriggerStay", luaTable, coll);
        }


        public LuaTable GetLuaTable()
        {
            return luaTable;
        }

        public void SetLuaTable(LuaTable lt){
            luaTable = lt;
        }

        [NoToLua]
        public void SetParams(LuaTable params_table)
        {
            if (luaTable == null) return;
            if (params_table == null)
                return;

            luaTable.SetTable("params", params_table);
        }
    }
}