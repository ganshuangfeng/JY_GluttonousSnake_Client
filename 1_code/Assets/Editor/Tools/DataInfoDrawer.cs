using UnityEngine;
using UnityEditor;

[CustomPropertyDrawer(typeof(DataInfo.Info))] 
public class DataInfoDrawer : PropertyDrawer
{
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        using (new EditorGUI.PropertyScope(position,label,property))
        {
            //设置属性名宽度
            EditorGUIUtility.labelWidth = 40;
            position.height = EditorGUIUtility.singleLineHeight;

            var prefabRect = new Rect(position)
            {
                width = 150,
                x = position.x
            };

            var keyRect = new Rect(prefabRect) 
            {
                y = prefabRect.y + EditorGUIUtility.singleLineHeight - 10
            };

            var prefabRect1 = new Rect(position)
            {
                width = 200,
                x = position.x + 160
            };

            var valueRect = new Rect(prefabRect1) 
            {
                y = prefabRect1.y + EditorGUIUtility.singleLineHeight - 10
            };

            var keyProperty = property.FindPropertyRelative("key");
            var valueProperty = property.FindPropertyRelative("value");

            keyProperty.stringValue = EditorGUI.TextField(keyRect, keyProperty.displayName,keyProperty.stringValue);
            valueProperty.stringValue = EditorGUI.TextField(valueRect, valueProperty.displayName,valueProperty.stringValue);
        }
    }
}

