using UnityEngine;
using System.Collections;

public class CameraDrag : MonoBehaviour 
{
    public float DragSpeed = 5f;
    public float SmoothRate = 0.7f;

    private Transform _Transform;

    private Vector3 _DragOrigin;
    private Vector3 _DragEnd;
    private float _Velocity;

    private bool _First = false;

    void Start()
    {
        _Transform = transform;
        
        _DragOrigin = Vector3.zero;
        _DragEnd = Vector3.zero;
        _Velocity = 0f;
    }

    void Update()
    {
        if (!_First && _Velocity != 0)
        {
            float smooth = (_Velocity > 0) ? SmoothRate : -SmoothRate;
            _Velocity -= smooth * Time.deltaTime;
            if (Mathf.Abs(_Velocity) < 0.01f) _Velocity = 0f;

            Vector3 move = new Vector3(_Velocity * -1, 0, 0);
            _Transform.Translate(move, Space.World);
        }

        if (Input.GetMouseButton(0))
        {
            if (!_First)
            {
                DragEnter();
                _First = true;
            }
            else
                DragUpdate();
        }
        else if (Input.GetMouseButtonUp(0))
        {
            _First = false;
        }
    }

    void DragEnter()
    {
        _Velocity = 0f;
        _DragOrigin = Camera.main.ScreenToViewportPoint(Input.mousePosition);
        _DragEnd = _DragOrigin;
    }

    void DragUpdate()
    {
        _DragOrigin = Camera.main.ScreenToViewportPoint(Input.mousePosition);
        _Velocity = (_DragOrigin.x - _DragEnd.x) * DragSpeed;

        Vector3 move = new Vector3(_Velocity * -1, 0, 0);
        _Transform.Translate(move, Space.World);

        _DragEnd = Camera.main.ScreenToViewportPoint(Input.mousePosition);
    }
}
